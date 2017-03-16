require "test_helper"

class SignupsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def signup_params(overrides = {})
    {
      username: "chance",
      password: "coloring-book",
      password_confirmation: "coloring-book",
      secret: AppConfig.account_creation_secret,
    }.merge(overrides)
  end

  test "#new smoke test" do
    get new_signup_url
  end

  test "#create creates a user and an account" do
    assert_difference "Account.count" do
      assert_difference "User.unscoped.count" do
        post(signups_url, params: signup_params)
      end
    end

    assert_redirected_to "/"
  end

  test "#create fails with invalid user" do
    assert_no_difference "User.unscoped.count" do
      post(signups_url, params: signup_params.merge(password_confirmation: "nope"))

      assert_response :unprocessable_entity
    end
  end

  test "#create fails with invalid secret" do
    assert_no_difference "User.unscoped.count" do
      post(signups_url, params: signup_params.merge(secret: "!!!"))

      assert_response :forbidden
    end
  end

  test "#create can work without secret if it's disabled" do
    AppConfig.account_creation_secret = nil

    assert_difference "User.unscoped.count" do
      post(signups_url, params: signup_params)
    end
  end

  test "#create enqueues default envelopes seed job" do
    assert_enqueued_with(job: SeedDefaultEnvelopesForAccountJob) do
      post(signups_url, params: signup_params)
    end
  end
end
