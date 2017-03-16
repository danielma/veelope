module EnvelopesHelper
  def envelope_balance_history_props(envelope)
    {
      initial_balance_cents: envelope.balance_at(3.months.ago).cents,
      designations: envelope_designations(envelope).map do |designation|
        {
          amount_cents: designation.amount_cents,
          posted_at: designation.bank_transaction.posted_at,
        }
      end,
    }
  end

  def envelope_designations(envelope)
    envelope.designations.
      last_months(3).
      joins(:bank_transaction).
      includes(:bank_transaction).
      order("bank_transactions.posted_at ASC")
  end
end
