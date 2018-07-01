require "test_helper"

class OFXAccountTest < ActiveSupport::TestCase
  def subject
    VeelopeOFX.new(fixture, bank_account: bank_account).account
  end

  def fixture
    File.read(file_fixture(fixture_name))
  end

  def fixture_name
    @fixture_name ||= "transactions.qfx"
  end

  attr_reader :bank_account

  test "#to_bank_account can return persisted account" do
    assert_equal bank_accounts(:west_imports), subject.to_bank_account
  end

  test "#to_bank_account can return a new account" do
    @fixture_name = "unknown_transactions.qfx"

    bank_account = subject.to_bank_account

    assert_predicate bank_account, :new_record?
    assert_equal "Bank.org Checking", bank_account.name
    assert_equal "depository", bank_account.type
    refute_nil bank_account.remote_identifier
  end

  test "#to_bank_account can return manual account" do
    @bank_account = bank_accounts(:west_transfers)

    assert { subject.to_bank_account == bank_account }
  end
end
