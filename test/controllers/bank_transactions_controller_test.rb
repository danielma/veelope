require "test_helper"

class BankTransactionsControllerTest < ActionDispatch::IntegrationTest
  setup :login

  def bank_transaction
    @bank_transaction ||= bank_transactions(:west_undesignated)
  end

  def bank_transaction_create_params(overrides = {})
    {
      bank_transaction: {
        amount_cents: "4000",
        bank_account_id: bank_accounts(:west_checking).id,
        payee: "Best Buy",
        posted_at: "2004-03-01",
        designations_attributes: [
          { envelope_id: envelopes(:groceries).id, amount_cents: "4000" },
        ],
      }.deep_merge(overrides),
    }
  end

  test "#index smoke test" do
    get bank_transactions_url
    assert_response :success
  end

  test "#edit smoke test" do
    get edit_bank_transaction_url(bank_transaction)
    assert_response :success
  end

  test "#new smoke test" do
    get new_bank_transaction_url
    assert_response :success
  end

  test "#create creates a transaction" do
    assert_difference "BankTransaction.unscoped.manual.count" do
      post(
        bank_transactions_url,
        params: bank_transaction_create_params,
      )
    end
  end

  test "#create transaction is invalid if designations amount isn't correct" do
    assert_no_difference "BankTransaction.unscoped.count" do
      post(
        bank_transactions_url,
        params: bank_transaction_create_params(
          designations_attributes: [
            { envelope_id: envelopes(:groceries).id, amount_cents: "-2000" },
          ],
        ),
      )
    end
  end

  test "#update can update designations" do
    assert_change -> { bank_transaction.reload.memo }, "New Memo" do
      assert_difference "Designation.unscoped.where(bank_transaction: bank_transaction).count", 2 do
        patch(
          bank_transaction_url(bank_transaction),
          params: {
            bank_transaction: {
              memo: "New Memo",
              designations_attributes: [
                { envelope_id: envelopes(:groceries).id, amount_cents: "-2500" },
                { envelope_id: envelopes(:blessing).id, amount_cents: "-1500" },
              ],
            },
          },
        )
      end
    end

    assert_redirected_to bank_transactions_url
  end

  test "#update fails with invalid designations" do
    assert_no_difference "Designation.unscoped.where(bank_transaction: bank_transaction).count" do
      patch(
        bank_transaction_url(bank_transaction),
        params: {
          bank_transaction: {
            memo: "New Memo",
            designations_attributes: [
              { envelope_id: envelopes(:groceries).id, amount_cents: "-2300" },
              { envelope_id: envelopes(:blessing).id, amount_cents: "-1500" },
            ],
          },
        },
      )
    end

    assert_response :success
  end

  test "#destroy destroys a transaction" do
    assert_difference "BankTransaction.count", -1 do
      delete bank_transaction_url(bank_transaction)
    end

    assert_redirected_to bank_transactions_url
  end
end
