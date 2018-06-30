module BankTransactionsHelper
  def designation_selector_props(bank_transaction, envelopes:, disabled: false)
    {
      bank_transaction: {
        id: bank_transaction.id,
        amount_cents: bank_transaction.amount_cents,
        envelopes: bank_transaction.envelopes.map { |e| e.slice(:id, :name) },
      },
      envelopes: envelopes_props(envelopes),
      disabled: disabled,
    }
  end

  def designation_editor_props(bank_transaction, envelopes:)
    {
      total_amount_cents: bank_transaction.amount_cents,
      envelopes: envelopes_props(envelopes),
      initial_designations: bank_transaction.designations.map do |designation|
        designation.slice(:id, :envelope_id, :amount_cents)
      end,
      is_new_record: bank_transaction.new_record?,
    }
  end

  def envelopes_props(envelopes)
    envelopes.map do |envelope|
      envelope.slice(:name, :full_name, :id)
    end
  end

  def designation_props(designation)
    designation.slice(:id, :envelope_id, :amount_cents)
  end
end
