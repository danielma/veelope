require "test_helper"

class OFXTransactionTest < ActiveSupport::TestCase
  def subject
    VeelopeOFX.new(fixture).transactions
  end

  def fixture
    File.read(file_fixture("transactions.qfx"))
  end

  test "#payee" do
    transactions = subject

    assert_equal "CHECK #1234", transactions[0].payee
    assert_equal "SHERPA CO OUTBOX CO: DARKTOOTH MCWING", transactions[1].payee
    assert_equal "To GAMBINO,CHILDISH Business Banking Transfer ??", transactions[2].payee
    assert_equal "Check Card: SQC*CHANCE THE RAPPER . /", transactions[3].payee
    assert_equal "BANKCORP BANK", transactions[4].payee
  end

  test "#to_bank_transaction can build new transaction" do
    transaction = subject.first.to_bank_transaction

    assert_equal "CHECK #1234", transaction.payee
    assert_equal bank_accounts(:west_imports), transaction.bank_account
    assert_equal Time.new(2017, 9, 29, 12).in_time_zone, transaction.posted_at
    assert_equal Money.new(-12000), transaction.amount
    assert_nil transaction.memo
    refute_nil transaction.remote_identifier
    assert_equal "import", transaction.source
    assert_predicate transaction, :valid?
  end

  test "#to_bank_transaction can find existing transaction" do
    refute_nil subject.map(&:to_bank_transaction).find(&:persisted?)
  end
end
