class CreateSignup
  include Service

  class InvalidSecretError < StandardError; end

  def initialize(user_attributes)
    @secret = user_attributes.delete(:secret)
    @user_attributes = user_attributes
  end

  def call
    call!
  rescue ActiveRecord::RecordInvalid
    failure(:invalid_user, account: account, user: user)
  rescue InvalidSecretError
    failure(:invalid_secret, account: account, user: user)
  end

  def check_account_creation_secret
    return unless AppConfig.account_creation_secret

    fail InvalidSecretError if secret != AppConfig.account_creation_secret
  end

  def call!
    check_account_creation_secret
    create_account_and_user

    SeedDefaultEnvelopesForAccountJob.perform_later(account.id)

    success(account: account, user: user)
  end

  private

  attr_reader :user_attributes, :secret

  def user
    @user ||= User.unscoped.new(user_attributes.merge(account: account))
  end

  def account
    @account ||= Account.new
  end

  def create_account_and_user
    Account.transaction do
      account.save!
      user.save!
    end
  end
end
