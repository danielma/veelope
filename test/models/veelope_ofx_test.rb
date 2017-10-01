require "test_helper"

class VeelopeOFXTest < ActiveSupport::TestCase
  def subject
    described_class.new(fixture)
  end

  def fixture
    File.read(file_fixture("transactions.qfx"))
  end

  test "has an account and transactions" do
    assert_predicate subject.account, :present?
    assert_predicate subject.transactions, :present?
  end

  test "account matches itself to an existing account with an identifier" do
    account = subject.account

    assert_equal bank_accounts(:west_imports).remote_identifier, account.identifier
  end

  test "transactions match themselves to existing transactions with an identifier" do
    transactions = subject.transactions
    transaction = bank_transactions(:already_imported)

    match = transactions.find { |t| t.identifier == transaction.remote_identifier }
    refute_nil match
  end
end
