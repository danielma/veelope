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
      source_remote.
        select("#{table_name}.*", "merge_candidates.id AS merge_candidate_id").
        joins(<<~SQL.squish)
          INNER JOIN #{table_name} as merge_candidates
            ON merge_candidates.id <> #{table_name}.id
            AND merge_candidates.bank_account_id = #{table_name}.bank_account_id
            AND merge_candidates.amount_cents = #{table_name}.amount_cents
            AND DATE_PART('day', merge_candidates.posted_at) - DATE_PART('day', #{table_name}.posted_at) <= 1
            AND merge_candidates.source <> #{table_name}.source
        SQL
    end,
  )

  accepts_nested_attributes_for :designations

  enum source: %i(remote manual import), _prefix: true

  monetize :amount_cents

  validate :amount_cents_is_not_zero
  validate :designations_total_equals_transaction_total, if: -> { designations.any? }
  validates :bank_account, :payee, :posted_at, :amount_cents, :source, presence: true
  validates :remote_identifier, uniqueness: true, allow_nil: true

  class << self
    def merge(transaction_a, transaction_b)
      grouped_transactions = [transaction_a, transaction_b].group_by(&:source_remote?)

      if (error = candidates_for_merge_error(transaction_a, transaction_b))
        error
      else
        [transaction_a.designations, transaction_b.designations].select(&:any?).flatten.each do |d|
          d.update!(bank_transaction: grouped_transactions[true].first)
        end
        grouped_transactions[false].first.reload.destroy!
      end
    end

    private

    def candidates_for_merge_error(transaction_a, transaction_b)
      ids = [transaction_a.id, transaction_b.id]
      candidate = candidate_for_merge.find_by(id: ids)

      if candidate.blank? || ids.exclude?(candidate.merge_candidate_id)
        MergeError.new("neither a candidate for merge!")
      elsif transaction_a.designations.any? && transaction_b.designations.any?
        MergeError.new("both transactions have designations!")
      end
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

  attr_accessor :merge_candidate

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
