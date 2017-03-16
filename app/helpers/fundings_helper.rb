module FundingsHelper
  def funding_editor_props(funding, envelopes:)
    {
      from_envelope_id: funding.from_envelope.id,
      available_balance_cents: funding.from_envelope.balance_cents,
      envelopes: envelopes_props(envelopes),
      designations: funding.designations.map do |designation|
        designation_props(designation)
      end,
    }
  end
end
