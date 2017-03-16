require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup :login

  test "should get edit" do
    get edit_account_url
    assert_response :success
  end

  test "#update smoke test" do
    put account_url, params: { account: { time_zone: "hi" } }
  end
end
