class EnvelopeGroup < ApplicationRecord
  acts_as_tenant(:account)

  default_scope -> { order(name: :asc) }

  has_many :envelopes, dependent: :destroy
  has_many :designations, through: :envelopes

  monetize :balance_cents

  def balance_cents
    designations.sum(:amount_cents)
  end
end
