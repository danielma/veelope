require 'test_helper'

class DesignationsControllerTest < ActionDispatch::IntegrationTest
  skip_all "Not implemented"

  setup do
    @designation = designations(:west_vons_groceries)
  end

  test "should get index" do
    get designations_url
    assert_response :success
  end

  test "should get new" do
    get new_designation_url
    assert_response :success
  end

  test "should create designation" do
    assert_difference('Designation.count') do
      post designations_url, params: { designation: { account_id: @designation.account_id, amount: @designation.amount, envelope_id: @designation.envelope_id, bank_transaction_id: @designation.bank_transaction_id } }
    end

    assert_redirected_to designation_url(Designation.last)
  end

  test "should show designation" do
    get designation_url(@designation)
    assert_response :success
  end

  test "should get edit" do
    get edit_designation_url(@designation)
    assert_response :success
  end

  test "should update designation" do
    patch designation_url(@designation), params: { designation: { account_id: @designation.account_id, amount: @designation.amount, envelope_id: @designation.envelope_id, bank_transaction_id: @designation.bank_transaction_id } }
    assert_redirected_to designation_url(@designation)
  end

  test "should destroy designation" do
    assert_difference('Designation.count', -1) do
      delete designation_url(@designation)
    end

    assert_redirected_to designations_url
  end
end
