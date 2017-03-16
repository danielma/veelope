class Funding
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_writer :designations_attributes

  validate :amount_is_available_in_from_envelope
  validates :amount, numericality: { greater_than: 0 }

  def from_envelope
    @from_envelope ||= Envelope.income_cash_pool
  end

  def designations_attributes
    @designations_attributes ||= []
  end

  def designations
    designations_attributes_array.map do |attributes|
      Designation.new(attributes)
    end
  end

  def save
    return false unless valid?

    bank_transaction.save
  end

  private

  def bank_transaction
    BankTransaction.new(
      bank_account: BankAccount.transfers,
      payee: "Funding #{Time.current.to_s(:date)}",
      posted_at: Time.current,
      amount: 0,
      source: "manual",
      designations: designations_with_from_envelope,
    )
  end

  def designations_with_from_envelope
    designations.concat [from_envelope_designation]
  end

  def from_envelope_designation
    Designation.new(envelope: from_envelope, amount: -amount)
  end

  def amount
    designations.sum(&:amount)
  end

  def designations_attributes_array
    case designations_attributes
    when Hash
      designations_attributes.values
    else
      designations_attributes
    end
  end

  def amount_is_available_in_from_envelope
    return if amount <= from_envelope.balance

    errors.add(:amount, "is more than is available in the Income Cash Pool")
  end
end
