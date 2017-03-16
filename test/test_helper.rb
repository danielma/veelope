ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/mock"
require_relative "support/custom_assertions"

Dir.glob(Rails.root.join("test/models/concerns/*.rb")).each { |file| require file }

module ActiveSupport
  class TestCase
    include CustomAssertions

    fixtures :all

    setup { ActsAsTenant.current_tenant = accounts(:west_family) }

    def self.skip_all(reason = nil)
      setup { skip(reason) }
    end

    def described_class
      self.class.name.gsub(/Test$/, "").constantize
    end
  end
end

module ActionDispatch
  class IntegrationTest
    def login(user = :kanye)
      u = users(user)

      post session_url, params: { username: u.username, password: u.username }

      ActsAsTenant.default_tenant = u.account

      assert_response :redirect
      follow_redirect!
    end

    teardown do
      ActsAsTenant.default_tenant = nil
    end
  end
end

class Object
  def expect(method_name, return_value = nil, args = [], count = 1)
    mock = MiniTest::Mock.new
    count.times { mock.expect(:call, return_value, args) }
    stub(method_name, mock) { yield }
    mock.verify
  end

  def assert_change(object, expected_final_value = :any_change)
    original_value = object.call
    yield
    final_value = object.call

    refute_equal(original_value, final_value, "Expected #{original_value.inspect} to change")
    return if expected_final_value == :any_change

    assert_equal(
      expected_final_value,
      final_value,
      "Expected #{original_value.inspect} to change to #{expected_final_value.inspect}, "\
      "but it changed to #{final_value.inspect}.",
    )
  end

  def refute_change(object)
    original_value = object.call
    yield
    final_value = object.call

    assert_equal(
      original_value,
      final_value,
      "Expected #{original_value.inspect} not to change, but it changed to #{final_value.inspect}.",
    )
  end
end
