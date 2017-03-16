class DashboardsController < ApplicationController
  def show
    @envelope_groups = EnvelopeGroup.all.includes(:envelopes)
    @envelope_balances = Designation.group(:envelope_id).sum(:amount_cents)
    @bank_accounts = BankAccount.all
  end
end
