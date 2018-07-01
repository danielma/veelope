# frozen_string_literal: true

require "test_helper"

module API
  module V1
    class BankAccountOFXsControllerTest < ActionDispatch::IntegrationTest
      setup :login

      test "import transactions when we recognize an account" do
        account = bank_accounts(:west_checking)

        assert_no_difference "BankAccount.unscoped.count" do
          assert_difference "BankTransaction.unscoped.where(bank_account: account).count", 4 do
            post(
              api_v1_bank_account_ofxs_url(account),
              params: { file: fixture_file_upload("/files/transactions.qfx") },
            )

            assert_response :created
          end
        end
      end

      test "import transactions when we don't recognize the account" do
        account = bank_accounts(:west_transfers)

        assert_no_difference "BankAccount.unscoped.count" do
          assert_difference "BankTransaction.unscoped.where(bank_account: account).count" do
            post(
              api_v1_bank_account_ofxs_url(account),
              params: { file: fixture_file_upload("/files/unknown_transactions.qfx") },
            )

            assert_response :created
          end
        end
      end
    end
  end
end
