class BankAccount < ApplicationRecord
  acts_as_tenant(:account)

  INITIAL_BALANCE_PAYEE = "__Initial Balance__".freeze
  TRANSFERS_NAME = "Transfers".freeze

  self.inheritance_column = "kind"

  validates :name, presence: true

  belongs_to :bank_connection, optional: true

  has_many :bank_transactions, dependent: :destroy, autosave: false

  after_save :update_initial_balance, if: -> { @needs_initial_balance_bank_transaction_save }

  enum type: %i(depository credit utility)

  monetize :balance_cents, :initial_balance_cents

  def self.transfers
    find_or_create_by!(name: TRANSFERS_NAME, type: "utility")
  end

  def balance_cents
    bank_transactions.sum(:amount_cents)
  end

  def remote_bank_account
    return unless bank_connection

    bank_connection.remote_accounts.find { |a| a.id == remote_identifier }
  end

  def initial_balance_persisted?
    initial_balance_bank_transaction.persisted?
  end

  def initial_balance_cents
    initial_balance_bank_transaction.amount_cents
  end

  def initial_balance_cents=(new_initial_balance_cents)
    @needs_initial_balance_bank_transaction_save = true

    initial_balance_bank_transaction.tap do |t|
      t.amount_cents = new_initial_balance_cents
    end
  end

  private

  def initial_balance_bank_transaction
    @initial_balance_bank_transaction ||= bank_transactions.
      find_or_initialize_by(payee: INITIAL_BALANCE_PAYEE).tap do |t|
        t.bank_account = self
        t.source = "manual"
        t.posted_at = Date.new(1880, 1, 1)
      end
  end

  def update_initial_balance
    initial_balance_bank_transaction.save!
  end
end
