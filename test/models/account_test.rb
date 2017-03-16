require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "#onboarded?" do
    assert_predicate accounts(:west_family), :onboarded?

    refute_predicate accounts(:bluth_family), :onboarded?
  end
end
