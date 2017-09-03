class DownloadAccountsAndTransactionsJob < ApplicationJob
  rescue_from(Plaid::RateLimitExceededError) do |error|
    Bugsnag.notify(error)
    retry_job wait: 20.minutes
  end

  rescue_from(Plaid::InvalidRequestError) do |error|
    Bugsnag.notify(error) do |notification|
      notification.severity = "error"
    end
  end

  def perform(bank_connection_id)
    job_scope(BankConnection, bank_connection_id) do |bank_connection|
      @bank_connection = bank_connection

      return if bank_connection.refreshing

      perform_in_scope
    end
  end

  def perform_in_scope
    job_finished_updates = {}

    bank_connection.update!(refreshing: true)

    create_accounts
    set_connection_institution
    create_transactions
    set_initial_balances
    job_finished_updates[:successfully_refreshed_at] = Time.current
  rescue Plaid::ItemError => e
    Bugsnag.notify(e) { |n| n.severity = "error" }
    job_finished_updates[:user_action_required_message] = e.error_message
  ensure
    bank_connection.update!(
      job_finished_updates.reverse_merge(
        user_action_required_message: nil,
        refreshing: false,
        refreshed_at: Time.current,
      ),
    )
  end

  private

  attr_reader :bank_connection

  def create_accounts
    @bank_accounts = bank_connection.remote_accounts.map do |account|
      BankAccount.find_or_create_by!(
        remote_identifier: account["account_id"],
        type: account["type"],
        bank_connection: bank_connection,
      ) do |a|
        a.name = account["name"]
      end
    end
  end

  def set_connection_institution
    bank_connection.update!(institution_name: bank_connection.remote_institution["name"])
  end

  def set_initial_balances
    bank_connection.remote_accounts.each do |remote_account|
      bank_account = @bank_accounts.find { |ba| ba.remote_identifier == remote_account["account_id"] }

      next if bank_account.initial_balance_persisted?

      bank_account.initial_balance_cents =
        remote_balance_cents(bank_account, remote_account) - bank_account.balance_cents
      bank_account.save!
    end
  end

  def remote_balance_cents(bank_account, remote_account)
    if bank_account.credit?
      remote_account["balances"]["current"] * -100
    else
      remote_account["balances"]["current"] * 100
    end
  end

  def create_transactions
    bank_connection.remote_transactions.each do |transaction|
      create_transaction(transaction)
    end
  end

  def create_transaction(transaction)
    bank_account = BankAccount.find_by!(remote_identifier: transaction["account_id"])
    BankTransaction.find_or_create_by!(
      remote_identifier: transaction["transaction_id"],
      source: "remote",
      bank_account: bank_account,
    ) do |t|
      t.posted_at = Date.parse(transaction["date"])
      t.amount = transaction["amount"] * -1
      t.payee = transaction["name"]
    end
  end
end
