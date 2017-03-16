require "test_helper"

class BankConnectionsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup :login

  def bank_connection
    @bank_connection ||= bank_connections(:wescom_credit_union)
  end

  test "#new smoke test" do
    get new_bank_connection_url
  end

  test "#create should add a BankConnection" do
    assert_difference "BankConnection.unscoped.where(plaid_access_token: '123').count" do
      struct = Struct.new(:access_token)

      Plaid::User.expect(:exchange_token, struct.new("123"), ["tok_123"]) do
        assert_enqueued_with(job: DownloadAccountsAndTransactionsJob) do
          post(bank_connections_url, params: { public_token: "tok_123" })
        end
      end
    end

    assert_redirected_to bank_connections_url
  end

  test "#refresh should enqueue download accounts job" do
    assert_enqueued_with(job: DownloadAccountsAndTransactionsJob) do
      post(refresh_bank_connection_url(bank_connection))
    end

    assert_redirected_to bank_connection_url(bank_connection)
  end

  test "#destroy removes a bank connection with accounts, transactions, and designations" do
    assert_difference "BankConnection.unscoped.count", -1 do
      assert_difference "BankAccount.unscoped.count", -2 do
        assert_difference "BankTransaction.unscoped.count", -3 do
          assert_difference "Designation.unscoped.count", -3 do
            delete bank_connection_url(bank_connection)
          end
        end
      end
    end

    assert_redirected_to bank_connections_url
  end
end
