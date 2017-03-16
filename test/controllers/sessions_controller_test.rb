require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "#new smoke test" do
    get new_session_url
  end

  test "#create fails for a missing user" do
    post session_url, params: { username: "nope", password: "nope" }

    assert_response :unauthorized
  end

  test "#create fails for wrong password" do
    post session_url, params: { username: "kanye", password: "Kimye" }

    assert_response :unauthorized
  end

  test "#create logs in a user" do
    post session_url, params: { username: "kanye", password: "kanye" }

    assert_redirected_to "/"
    get "/"
  end

  test "#destroy clears session values" do
    post session_url, params: { username: "kanye", password: "kanye" }

    assert_redirected_to "/"

    delete session_url
    follow_redirect!
    assert_redirected_to new_session_url
  end
end
