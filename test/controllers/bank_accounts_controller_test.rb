require "test_helper"

class BankAccountsControllerTest < ActionDispatch::IntegrationTest
  setup :login

  def bank_account
    @bank_account ||= bank_accounts(:west_savings)
  end

  test "#index smoke test" do
    get bank_accounts_url
    assert_response :success
  end

  test "#edit smoke test" do
    get edit_bank_account_url(bank_account)
    assert_response :success
  end

  test "#update should be able to set initial balance" do
    assert_difference "BankTransaction.unscoped.where(bank_account: bank_account).count" do
      patch(
        bank_account_url(bank_account),
        params: {
          bank_account: { initial_balance_cents: "10101" },
        },
      )
    end
  end
end
