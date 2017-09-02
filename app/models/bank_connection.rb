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
    response = Plaid.client.item.public_token.exchange(public_token)

    new(plaid_access_token: response["access_token"])
  end

  def remote_accounts
    @remote_accounts ||= Plaid.client.accounts.get(plaid_access_token)["accounts"]
  end

  def remote_institution
    @remote_institution ||=
      Plaid.client.institutions.get_by_id(plaid_item["institution_id"])["institution"]
  end

  def remote_transactions(start_date: 90.days.ago.to_date, end_date: Date.current)
    transactions = []
    response = { "total_transactions" => 1 }
    offset = 0

    while transactions.length < response["total_transactions"]
      response = Plaid.client.transactions.get(
        plaid_access_token,
        start_date,
        end_date,
        offset: offset,
      )

      offset += response["transactions"].count
      transactions += response["transactions"]
    end

    transactions.reject do |transaction|
      transaction["pending"]
    end
  end

  def refresh
    DownloadAccountsAndTransactionsJob.perform_later(id)
  end

  private

  def plaid_item
    @plaid_item ||= Plaid.client.item.get(plaid_access_token)["item"]
  end
end
