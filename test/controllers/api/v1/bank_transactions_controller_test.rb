require "test_helper"

module API
  module V1
    class BankTransactionsControllerTest < ActionDispatch::IntegrationTest
      setup :login

      test "should create" do
        assert_difference "BankTransaction.unscoped.where(payee: 'UBER').count" do
          post api_v1_bank_transactions_url, params: {
            bank_transaction: {
              payee: "UBER",
              source: "remote",
              bank_account_id: bank_accounts(:west_savings).id,
              posted_at: Date.current,
              remote_identifier: Digest::MD5.hexdigest("remote-identifier"),
              amount_cents: -564,
            },
          }

          assert_response :created
        end
      end

      test "should have errors" do
        post api_v1_bank_transactions_url, params: {
          bank_transaction: {
            source: "remote",
            bank_account: bank_accounts(:west_savings),
            posted_at: Date.current,
            remote_identifier: Digest::MD5.hexdigest("remote-identifier"),
            amount_cents: -564,
          },
        }

        assert_response :unprocessable_entity
      end
    end
  end
end
