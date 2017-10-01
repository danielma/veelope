class OFXAccount
  def initialize(account, organization:)
    @account = account
    @organization = organization
  end

  def identifier
    Digest::MD5.hexdigest(raw_identifier)
  end

  def to_bank_account
    BankAccount.find_or_initialize_by(remote_identifier: identifier) do |ba|
      ba.name = name
      ba.type = type
    end
  end

  private

  attr_reader :account, :organization

  def name
    "#{organization.name} #{account.type.capitalize}"
  end

  def type
    case account.type
    when :checking
      "depository"
    else
      fail "sorry, don't know how to deal with this type! #{account.type}"
    end
  end

  def raw_identifier
    [account.bank_id, account.id, AppConfig.identifier_salt].compact.map(&:strip).join("-")
  end
end
