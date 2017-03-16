require 'test_helper'

class EnvelopeGroupsControllerTest < ActionDispatch::IntegrationTest
  skip_all "¯\_(ツ)_/¯"

  setup do
    @envelope_group = envelope_groups(:food)
  end

  test "should get index" do
    get envelope_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_envelope_group_url
    assert_response :success
  end

  test "should create envelope_group" do
    assert_difference('EnvelopeGroup.count') do
      post envelope_groups_url, params: { envelope_group: { account_id: @envelope_group.account_id, name: @envelope_group.name } }
    end

    assert_redirected_to envelope_group_url(EnvelopeGroup.last)
  end

  test "should show envelope_group" do
    get envelope_group_url(@envelope_group)
    assert_response :success
  end

  test "should get edit" do
    get edit_envelope_group_url(@envelope_group)
    assert_response :success
  end

  test "should update envelope_group" do
    patch envelope_group_url(@envelope_group), params: { envelope_group: { account_id: @envelope_group.account_id, name: @envelope_group.name } }
    assert_redirected_to envelope_group_url(@envelope_group)
  end

  test "should destroy envelope_group" do
    assert_difference('EnvelopeGroup.count', -1) do
      delete envelope_group_url(@envelope_group)
    end

    assert_redirected_to envelope_groups_url
  end
end
