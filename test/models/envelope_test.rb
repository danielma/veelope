require "test_helper"

class EnvelopeTest < ActiveSupport::TestCase
  include AssertValidFixtures

  test "protects some envelopes" do
    SeedDefaultEnvelopesForAccountJob.perform_now(ActsAsTenant.current_tenant.id)

    envelope = Envelope.find_by(name: "Income Cash Pool")

    assert_predicate envelope, :readonly?
    assert_raises ActiveRecord::ReadOnlyRecord do
      refute envelope.destroy
    end
  end
end
