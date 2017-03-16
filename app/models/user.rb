class User < ApplicationRecord
  acts_as_tenant(:account)

  has_secure_password

  validates :username, uniqueness: true, presence: true

  before_create :generate_auth_token

  private

  def generate_auth_token
    self.auth_token ||= SecureRandom.hex(52)
  end
end
