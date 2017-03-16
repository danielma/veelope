class Account < ApplicationRecord
  with_options dependent: :destroy do
    has_many :envelopes
    has_many :envelope_groups
    has_many :bank_accounts
    has_many :users
    has_many :bank_connections
  end

  def onboarded?
    time_zone && bank_connections.any?
  end

  def onboarding_step
    if time_zone.blank?
      :time_zone
    else
      :create_connection
    end
  end
end
