require "test_helper"

class FundingsControllerTest < ActionDispatch::IntegrationTest
  setup :login

  test "#new smoke test" do
    get new_funding_url
    assert_response :success
  end

  test "#create should create a transaction that drains the income cash pool" do
    assert_difference "BankTransaction.unscoped.count" do
      assert_difference "Designation.unscoped.count", 3 do
        assert_difference(
          "Envelope.unscoped.income_cash_pool.balance_cents",
          -10000,
        ) do
          post(
            fundings_url,
            params: {
              funding: {
                designations_attributes: {
                  0 => { envelope_id: envelopes(:groceries).id, amount_cents: 4400 },
                  1 => { envelope_id: envelopes(:blessing).id, amount_cents: 5600 },
                },
              },
            },
          )
        end
      end
    end

    assert_redirected_to root_url
  end

  test "#create should fail if funding is too large" do
    post(
      fundings_url,
      params: {
        funding: {
          designations_attributes: [
            {
              envelope_id: envelopes(:groceries),
              amount_cents: 10001,
            },
          ],
        },
      },
    )

    assert_response :success
  end
end
