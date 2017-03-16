class Transfer
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :from_envelope_id, :to_envelope_id
  attr_writer :amount_cents

  validate :envelopes_are_different
  validate :amount_is_not_zero
  validates :from_envelope, :to_envelope, presence: true

  def amount
    Money.new(amount_cents)
  end

  def amount_cents
    @amount_cents ||= 0
  end

  def from_envelope
    from_envelope_id && Envelope.find(from_envelope_id)
  end

  def from_envelope=(new_from_envelope)
    self.from_envelope_id = new_from_envelope.id
  end

  def to_envelope
    to_envelope_id && Envelope.find(to_envelope_id)
  end

  def to_envelope=(new_to_envelope)
    self.to_envelope_id = new_to_envelope.id
  end

  def save
    return false unless valid?

    bank_transaction.save
  end

  private

  def bank_transaction
    BankTransaction.new(
      bank_account: BankAccount.transfers,
      payee: payee,
      posted_at: Time.current,
      amount: 0,
      source: "manual",
      designations: designations,
    )
  end

  def payee
    "Transfer from #{from_envelope.name} to #{to_envelope.name}"
  end

  def designations
    [
      Designation.new(amount: -amount, envelope: from_envelope),
      Designation.new(amount: amount, envelope: to_envelope),
    ]
  end

  def envelopes_are_different
    return unless from_envelope == to_envelope

    errors.add(:base, "Envelopes cannot be the same")
  end

  def amount_is_not_zero
    return unless amount.zero?

    errors.add(:amount_cents, "cannot be zero")
  end
end
