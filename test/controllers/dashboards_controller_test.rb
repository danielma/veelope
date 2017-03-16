require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup :login

  test "#index smoke test" do
    get root_url
    assert_response :success
  end
end
