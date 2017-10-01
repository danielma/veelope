class OFXAccount
  def initialize(account, organization:, source:)
    @account = account
    @organization = organization
    @source = source
  end

  def identifier
    Digest::MD5.hexdigest(raw_identifier)
  end

  def to_bank_account
    BankAccount.find_or_initialize_by(remote_identifier: identifier) do |ba|
      ba.name = name
      ba.type = bank_account_type ||
        fail("sorry, don't know how to deal with this type! #{account.type}")
    end
  end

  private

  attr_reader :account, :organization, :source

  def name
    "#{organization.name} #{type.to_s.capitalize}"
  end

  def type
    return account.type if account.type.present?

    :credit if source.include?("CREDITCARDMSG")
  end

  def bank_account_type
    case type
    when :checking, :savings
      "depository"
    when :credit
      "credit"
    end
  end

  def raw_identifier
    [account.bank_id, account.id, AppConfig.identifier_salt].compact.map(&:strip).join("-")
  end
end
