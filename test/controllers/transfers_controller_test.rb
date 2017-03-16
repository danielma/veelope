require "test_helper"

class TransfersControllerTest < ActionDispatch::IntegrationTest
  setup :login

  test "#new smoke test" do
    get new_transfer_url
    assert_response :success
  end

  test "#create transfers between envelopes" do
    groceries = envelopes(:groceries)
    blessing = envelopes(:blessing)

    assert_difference "blessing.reload.balance_cents", -2000 do
      assert_difference "groceries.reload.balance_cents", 2000 do
        transfer_params = {
          from_envelope_id: blessing.id,
          to_envelope_id: groceries.id,
          amount_cents: 2000,
        }

        post transfers_url, params: { transfer: transfer_params }
      end
    end
  end
end
