class Designation < ApplicationRecord
  acts_as_tenant(:account)

  belongs_to :bank_transaction
  belongs_to :envelope

  monetize :amount_cents

  scope :last_months, ->(count) { posted_after(count.months.ago) }

  scope(
    :posted_after,
    ->(time) { joins(:bank_transaction).where("posted_at > ?", time) },
  )

  scope(
    :posted_before,
    ->(time) { joins(:bank_transaction).where("posted_at <= ?", time) },
  )
end
