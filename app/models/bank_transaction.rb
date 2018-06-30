class BankTransaction < ApplicationRecord
  acts_as_tenant(:account)

  class MergeError < StandardError; end

  belongs_to :bank_account
  has_many :designations, dependent: :destroy, inverse_of: :bank_transaction
  has_many :envelopes, through: :designations

  default_scope -> { order(posted_at: :desc) }

  scope :credit, -> { where(amount_cents: 1..Float::INFINITY) }
  scope :debit, -> { where(amount_cents: -Float::INFINITY..0) }

  scope :undesignated, -> { left_outer_joins(:designations).where(designations: { id: nil }) }
  scope :designated, -> { joins(:designations) }

  scope(
    :candidate_for_merge,
    lambda do
      joins(<<~SQL.squish).select("#{table_name}.*", "merge_candidates.id AS merge_candidate_id")
        INNER JOIN #{table_name} as merge_candidates
          ON merge_candidates.id <> #{table_name}.id
          AND LOWER(merge_candidates.payee) = LOWER(#{table_name}.payee)
          AND merge_candidates.amount_cents = #{table_name}.amount_cents
          AND #{table_name}.created_at < merge_candidates.created_at
      SQL
    end,
  )

  accepts_nested_attributes_for :designations

  enum source: %i(remote manual import)

  monetize :amount_cents

  validate :amount_cents_is_not_zero
  validate :designations_total_equals_transaction_total, if: -> { designations.any? }
  validates :bank_account, :payee, :posted_at, :amount_cents, :source, presence: true
  validates :remote_identifier, uniqueness: true, allow_nil: true

  class << self
    def candidates_for_merge?(transaction_a, transaction_b)
      candidate = candidate_for_merge.find_by(id: [transaction_a.id, transaction_b.id])

      candidate.present? &&
        [transaction_a.id, transaction_b.id].include?(candidate.merge_candidate_id)
    end
  end

  def designations_attributes=(*args)
    designations.clear
    super(*args)
  end

  def amount_for_envelope(envelope_or_id)
    return amount if envelope_or_id.nil?

    id = envelope_or_id.respond_to?(:id) ? envelope_or_id.id : envelope_or_id
    id = id.to_i

    designation = designations.find { |d| d.envelope_id == id }
    designation ? designation.amount : amount
  end

  def merge!(other)
    i_have_designations = designations.any?
    other_has_designations = other.designations.any?

    if !candidates_for_merge?(self, other)
      MergeError.new("neither a candidate for merge!")
    elsif i_have_designations && other_has_designations
      MergeError.new("both transactions have designations!")
    else
      to_delete = i_have_designations ? other : self
      to_delete.destroy!
    end
  end

  delegate :candidates_for_merge?, to: :class

  private

  def amount_cents_is_not_zero
    return unless amount_cents.zero?
    return if payee == BankAccount::INITIAL_BALANCE_PAYEE
    return if bank_account && bank_account_id == BankAccount.transfers.id

    errors.add(:amount, "must not be 0")
  end

  def designations_total_equals_transaction_total
    return if designations.sum(&:amount) == amount

    errors.add(
      :designations,
      "amount #{designations.sum(&:amount)} does not match transaction amount #{amount}",
    )
  end
end
