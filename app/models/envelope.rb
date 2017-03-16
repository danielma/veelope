class Envelope < ApplicationRecord
  acts_as_tenant(:account)

  INCOME_CASH_POOL_NAME = "Income Cash Pool".freeze
  PROTECTED_ENVELOPES = [INCOME_CASH_POOL_NAME].freeze

  default_scope -> { joins(:envelope_group).order("envelope_groups.name ASC", name: :asc) }

  belongs_to :envelope_group
  has_many :designations, dependent: :destroy
  has_many :bank_transactions, through: :designations

  monetize :balance_cents

  def self.income_cash_pool
    find_or_initialize_by(name: INCOME_CASH_POOL_NAME)
  end

  def full_name
    "#{envelope_group.name}: #{name}"
  end

  def balance_at(time = Time.current)
    Money.new(designations.posted_before(time).sum(:amount_cents))
  end

  def balance_cents
    designations.sum(:amount_cents)
  end

  def readonly?
    return true if PROTECTED_ENVELOPES.include?(name) && persisted?

    super
  end
end
