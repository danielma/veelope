require "test_helper"

class BankConnectionTest < ActiveSupport::TestCase
  include AssertValidFixtures

  test ".from_plaid_public_token returns a new instance with a token" do
    response = { "access_token" => "token" }

    Plaid.client.item.public_token.expect(:exchange, response, ["tok_123"]) do
      connection = described_class.from_plaid_public_token("tok_123")

      assert_equal "token", connection.plaid_access_token
    end
  end

  test "#user_action_required? if message is set" do
    refute_predicate bank_connections(:wescom_credit_union), :user_action_required?
    assert_predicate bank_connections(:capital_one), :user_action_required?
  end
end
