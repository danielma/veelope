require "test_helper"

class DownloadAccountsAndTransactionsJobTest < ActiveJob::TestCase
  def bank_connection
    @bank_connection ||= bank_connections(:wescom_credit_union)
  end

  test "sets institution_name for the connection" do
    assert_change -> { bank_connection.reload.institution_name }, fake_plaid_institution.name do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end
  end

  test "sets refreshed_at for connection" do
    Timecop.freeze do
      assert_change -> { bank_connection.reload.refreshed_at.to_s }, Time.current.to_s do
        stub_plaid_methods do
          described_class.perform_now(bank_connection.id)
        end
      end
    end
  end

  test "does nothing if connection is already refreshing" do
    bank_connection.update!(refreshing: true)
    described_class.perform_now(bank_connection.id)
  end

  test "ensures that refreshing is false after running" do
    stub_plaid_methods do
      described_class.perform_now(bank_connection.id)
    end

    refute_predicate bank_connection.reload, :refreshing
  end

  test "creates accounts from plaid" do
    assert_difference "BankAccount.count", 2 do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end

    bank_account = BankAccount.reorder(id: :desc).first
    assert_equal "ac_2", bank_account.remote_identifier
    assert_equal "credit", bank_account.type
    assert_equal "Super Fancy Credit", bank_account.name
  end

  test "creates accounts with initial balance if missing" do
    stub_plaid_methods do
      described_class.perform_now(bank_connection.id)
    end

    bank_account = BankAccount.find_by!(remote_identifier: "ac_1")
    assert_equal(Money.new((11_132.02 - 900) * 100), bank_account.initial_balance)
    stub_plaid_methods do
      assert_equal bank_account.remote_bank_account.current_balance, bank_account.balance
    end

    bank_account = BankAccount.find_by!(remote_identifier: "ac_2")
    assert_equal(Money.new((-40 + 120.4) * 100), bank_account.initial_balance)
    stub_plaid_methods do
      assert_equal(-bank_account.remote_bank_account.current_balance, bank_account.balance)
    end
  end

  test "doesn't create initial balance if it exists" do
    bank_account = BankAccount.create!(name: "Account", remote_identifier: "ac_1", type: "credit")
    bank_account.initial_balance_cents = 0
    bank_account.save!

    stub_plaid_methods do
      described_class.perform_now(bank_connection.id)
    end

    assert_equal Money.new(0), bank_account.reload.initial_balance
  end

  test "account creation is idempotent" do
    assert_difference "BankAccount.count", 2 do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end

    assert_no_difference "BankAccount.count" do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end
  end

  test "adds transactions from plaid" do
    assert_difference "BankTransaction.remote.count", 2 do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end

    bank_account = BankAccount.find_by!(remote_identifier: "ac_1")

    bank_transaction = bank_account.bank_transactions.find_by!(remote_identifier: "tr_2")
    assert_equal "tr_2", bank_transaction.remote_identifier
    assert_equal bank_account, bank_transaction.bank_account
    assert_equal Time.zone.local(2016, 10, 12), bank_transaction.posted_at
    assert_equal Money.new(90000), bank_transaction.amount
  end

  test "transaction creation is idempotent" do
    assert_difference "BankTransaction.remote.count", 2 do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end

    assert_no_difference "BankTransaction.count" do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end
  end

  def stub_plaid_methods
    Plaid::User.expect(:load, fake_plaid_user, [:connect, bank_connection.plaid_access_token]) do
      Plaid::Institution.stub(:get, fake_plaid_institution, [:ins_99999]) do
        yield
      end
    end
  end

  def fake_plaid_user
    @fake_plaid_user ||= (
      user = Plaid::User.new({})

      def user.accounts
        return nil unless @transactions_called

        [
          Plaid::Account.new(
            "_id" => "ac_1",
            "type" => "depository",
            "meta" => { "name" => "Regular Savings" },
            "institution_type" => "ins_99999",
            "balance" => {
              "available" => 11_120.94,
              "current" => 11_132.02,
            },
          ),
          Plaid::Account.new(
            "_id" => "ac_2",
            "type" => "credit",
            "meta" => { "name" => "Super Fancy Credit" },
            "institution_type" => "ins_99999",
            "balance" => {
              "available" => 1000,
              "current" => 40,
            },
          ),
        ]
      end

      def user.transactions(*)
        @transactions_called = true

        [
          Plaid::Transaction.new(
            "_id" => "tr_1",
            "_account" => "ac_2",
            "date" => "2016-10-10",
            "amount" => 120.4,
            "name" => "WAL-MART 999#33",
            "pending" => false,
          ),
          Plaid::Transaction.new(
            "_id" => "tr_2",
            "_account" => "ac_1",
            "date" => "2016-10-12",
            "amount" => -900,
            "name" => "DIRECT DEPOSIT",
            "pending" => false,
          ),
        ]
      end

      user
    )
  end

  def fake_plaid_institution
    Plaid::Institution.new("name" => "Plaid Bank of California", "products" => [])
  end
end
