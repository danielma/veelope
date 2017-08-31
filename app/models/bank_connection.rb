class BankConnection < ApplicationRecord
  acts_as_tenant(:account)

  scope(
    :candidate_for_refresh,
    lambda do
      where(refreshing: false).
      where("refreshed_at IS NULL OR refreshed_at < ?", 3.hours.ago)
    end,
  )

  has_many :bank_accounts, dependent: :destroy

  def self.from_plaid_public_token(public_token)
    new_plaid_user = Plaid::User.exchange_token(public_token)

    new(plaid_access_token: new_plaid_user.access_token)
  end

  def remote_accounts
    remote_transactions
    plaid_user.accounts
  end

  def remote_institution
    @remote_institution ||= Plaid::Institution.get(remote_accounts.first.institution)
  end

  def remote_transactions(pending: false, account_id: nil, start_date: nil, end_date: nil)
    plaid_user.transactions(
      pending: pending,
      account_id: account_id,
      start_date: start_date || 90.days.ago.to_date,
      end_date: end_date,
    )
  end

  def refresh
    DownloadAccountsAndTransactionsJob.perform_later(id)
  end

  private

  def plaid_user
    @plaid_user ||= Plaid::User.load(:connect, plaid_access_token)
  end
end
