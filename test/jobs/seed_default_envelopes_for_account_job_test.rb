require "test_helper"

class SeedDefaultEnvelopesForAccountJobTest < ActiveJob::TestCase
  def account
    @account ||= accounts(:west_family)
  end

  test "should seed default envelopes from a YAML file describing them" do
    assert_change -> { Envelope.count } do
      assert_change -> { EnvelopeGroup.count } do
        described_class.perform_now(account.id)
      end
    end

    assert EnvelopeGroup.find_by(name: "Government")
    assert Envelope.find_by(name: "Taxes")
  end
end
