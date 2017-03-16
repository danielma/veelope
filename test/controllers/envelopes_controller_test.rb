require "test_helper"

class EnvelopesControllerTest < ActionDispatch::IntegrationTest
  setup :login

  setup do
    @envelope = envelopes(:groceries)
  end

  test "should get index" do
    get envelopes_url
    assert_response :success
  end

  test "should get new" do
    skip
    get new_envelope_url
    assert_response :success
  end

  test "should create envelope" do
    skip
    assert_difference("Envelope.count") do
      post envelopes_url, params: { envelope: { account_id: @envelope.account_id, envelope_group_id: @envelope.envelope_group_id, name: @envelope.name } }
    end

    assert_redirected_to envelope_url(Envelope.last)
  end

  test "should show envelope" do
    get envelope_url(@envelope)
    assert_response :success
  end

  test "should get edit" do
    skip
    get edit_envelope_url(@envelope)
    assert_response :success
  end

  test "should update envelope" do
    skip
    patch envelope_url(@envelope), params: { envelope: { account_id: @envelope.account_id, envelope_group_id: @envelope.envelope_group_id, name: @envelope.name } }
    assert_redirected_to envelope_url(@envelope)
  end

  test "should destroy envelope" do
    skip
    assert_difference("Envelope.count", -1) do
      delete envelope_url(@envelope)
    end

    assert_redirected_to envelopes_url
  end
end
