require "test_helper"

module API
  module V1
    class OFXsControllerTest < ActionDispatch::IntegrationTest
      setup :login

      test "import transactions into known account" do
        assert_no_difference "BankAccount.unscoped.count" do
          assert_difference "BankTransaction.unscoped.count", 4 do
            post api_v1_ofxs_url, params: { file: fixture_file_upload("/files/transactions.qfx") }

            assert_response :created
          end
        end
      end

      test "import transactions into unknown account" do
        assert_difference "BankAccount.unscoped.count" do
          assert_difference "BankTransaction.unscoped.count" do
            post(
              api_v1_ofxs_url,
              params: { file: fixture_file_upload("/files/unknown_transactions.qfx") },
            )

            assert_response :created
          end
        end
      end
    end
  end
end
