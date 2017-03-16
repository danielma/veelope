class DownloadAccountsAndTransactionsJob < ApplicationJob
  def perform(bank_connection_id)
    job_scope(BankConnection, bank_connection_id) do |bank_connection|
      @bank_connection = bank_connection

      perform_in_scope
    end
  end

  def perform_in_scope
    return if bank_connection.refreshing

    bank_connection.update!(refreshing: true)

    create_accounts
    set_connection_institution
    create_transactions
    set_initial_balances
    bank_connection.update!(refreshed_at: Time.current)
  ensure
    bank_connection.update!(refreshing: false)
  end

  private

  attr_reader :bank_connection

  def create_accounts
    @bank_accounts = bank_connection.remote_accounts.map do |account|
      BankAccount.find_or_create_by!(
        remote_identifier: account.id,
        type: account.type,
        bank_connection: bank_connection,
      ) do |a|
        a.name = account.name
      end
    end
  end

  def set_connection_institution
    bank_connection.update!(institution_name: bank_connection.remote_institution.name)
  end

  def set_initial_balances
    bank_connection.remote_accounts.each do |remote_account|
      bank_account = @bank_accounts.find { |ba| ba.remote_identifier == remote_account.id }

      next if bank_account.initial_balance_persisted?

      bank_account.initial_balance_cents =
        remote_balance_cents(bank_account, remote_account) - bank_account.balance_cents
      bank_account.save!
    end
  end

  def remote_balance_cents(bank_account, remote_account)
    if bank_account.credit?
      remote_account.current_balance * -100
    else
      remote_account.current_balance * 100
    end
  end

  def create_transactions
    bank_connection.remote_transactions.each do |transaction|
      create_transaction(transaction)
    end
  end

  def create_transaction(transaction)
    bank_account = BankAccount.find_by!(remote_identifier: transaction.account_id)
    BankTransaction.find_or_create_by!(
      remote_identifier: transaction.id,
      source: "remote",
      bank_account: bank_account,
    ) do |t|
      t.posted_at = transaction.date
      t.amount = transaction.amount * -1
      t.payee = transaction.name
    end
  end
end
