class OFXTransaction
  def initialize(transaction, account:)
    @transaction = transaction
    @account = account
  end

  def identifier
    Digest::MD5.hexdigest(raw_identifier)
  end

  def payee
    raw_payee.gsub(/\s+/, " ")
  end

  def to_bank_transaction
    BankTransaction.find_or_initialize_by(remote_identifier: identifier) do |bt|
      bt.payee = payee
      bt.bank_account = account.to_bank_account
      bt.posted_at = posted_at
      bt.amount_cents = amount_in_pennies
      bt.remote_identifier = identifier
      bt.source = "import"
    end
  end

  private

  delegate :type,
           :check_number,
           :posted_at,
           :amount_in_pennies,
           to: :transaction

  attr_reader :transaction, :account

  def raw_payee
    transaction.memo.presence ||
      transaction.payee.presence ||
      transaction.name.presence ||
      check_payee
  end

  def check_payee
    return unless type == :check

    "CHECK ##{check_number}"
  end

  def raw_identifier
    [
      transaction.posted_at.to_date.to_s,
      transaction.fit_id,
      transaction.amount.to_s,
      payee,
      AppConfig.identifier_salt,
    ].compact.map(&:strip).join("-")
  end
end
