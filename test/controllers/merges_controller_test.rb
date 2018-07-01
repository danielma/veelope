# frozen_string_literal: true

require "test_helper"

class MergesControllerTest < ActionDispatch::IntegrationTest
  setup :login

  test "#index lists candidates for merge" do
    get merges_url

    assert_response :success

    expected_candidate = bank_transactions(:west_vons_needs_merge)
    mergeable = bank_transactions(:west_vons)

    url = merges_url(mergeable_a: expected_candidate, mergeable_b: mergeable)

    assert_select "form[action='#{url}']"
  end

  test "#create merges" do
    expected_candidate = bank_transactions(:west_vons)
    mergeable = bank_transactions(:west_vons_needs_merge)

    assert_difference "BankTransaction.unscoped.count", -1 do
      post merges_url(mergeable_a: expected_candidate, mergeable_b: mergeable)
    end

    assert_redirected_to merges_url
  end

  test "#merge returns an error if transactions are not candidates for merge" do
    original = bank_transactions(:west_vons)
    candidate = bank_transactions(:west_undesignated)

    assert_no_difference "BankTransaction.unscoped.count" do
      post merges_url(mergeable_a: original, mergeable_b: candidate)
    end

    assert_redirected_to merges_url
    follow_redirect!
    assert_select ".alert--danger"
  end
end
