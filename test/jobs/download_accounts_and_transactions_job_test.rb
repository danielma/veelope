require "test_helper"

class DownloadAccountsAndTransactionsJobTest < ActiveJob::TestCase
  def bank_connection
    @bank_connection ||= bank_connections(:wescom_credit_union)
  end

  test "sets institution_name for the connection" do
    assert_change -> { bank_connection.reload.institution_name }, "Cool Bank" do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end
  end

  test "sets refreshed_at for connection" do
    Timecop.freeze(Time.current.round) do
      assert_change -> { bank_connection.reload.refreshed_at }, Time.current do
        stub_plaid_methods do
          described_class.perform_now(bank_connection.id)
        end
      end
    end
  end

  test "sets successfully_refreshed_at for connection" do
    Timecop.freeze(Time.current.round) do
      assert_change -> { bank_connection.reload.successfully_refreshed_at }, Time.current do
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

    bank_account = BankAccount.reorder(remote_identifier: :asc).second
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

    stub_plaid_accounts do
      assert_equal(
        Money.new(bank_account.remote_bank_account["balances"]["current"] * 100),
        bank_account.balance,
      )
    end

    bank_account = BankAccount.find_by!(remote_identifier: "ac_2")
    assert_equal(Money.new((-40 + 120.4 + 40) * 100), bank_account.initial_balance)
    stub_plaid_accounts do
      assert_equal(
        Money.new(-bank_account.remote_bank_account["balances"]["current"] * 100),
        bank_account.balance,
      )
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
    assert_difference "BankTransaction.remote.count", 3 do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end

    bank_account = BankAccount.find_by!(remote_identifier: "ac_1")

    bank_transaction = bank_account.bank_transactions.find_by!(remote_identifier: "tr_2")
    assert_equal "tr_2", bank_transaction.remote_identifier
    assert_equal "DIRECT DEPOSIT", bank_transaction.payee
    assert_equal bank_account, bank_transaction.bank_account
    assert_equal Time.zone.local(2016, 10, 12), bank_transaction.posted_at
    assert_equal Money.new(90000), bank_transaction.amount
  end

  test "gets all pages of transactions" do
    assert_difference "BankTransaction.remote.count", 3 do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end

    bank_account = BankAccount.find_by!(remote_identifier: "ac_2")

    bank_transaction = bank_account.bank_transactions.find_by!(remote_identifier: "tr_4")
    assert_equal "tr_4", bank_transaction.remote_identifier
    assert_equal "UBER SF****POOL", bank_transaction.payee
    assert_equal bank_account, bank_transaction.bank_account
    assert_equal Time.zone.local(2016, 11, 11), bank_transaction.posted_at
    assert_equal Money.new(-4_000), bank_transaction.amount
  end

  test "ignores pending transactions from plaid" do
    assert_difference "BankTransaction.remote.count", 3 do
      stub_plaid_methods do
        described_class.perform_now(bank_connection.id)
      end
    end

    bank_account = BankAccount.find_by!(remote_identifier: "ac_1")

    assert_nil bank_account.bank_transactions.find_by(remote_identifier: "tr_3")
  end

  test "transaction creation is idempotent" do
    assert_difference "BankTransaction.remote.count", 3 do
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

  test "sets user_action_required_message" do
    Plaid.client.accounts.stub(
      :get,
      ->(_) { fail Plaid::ItemError.new("TYPE", "CODE", "message", "", "") },
    ) do
      assert_change -> { bank_connection.reload.user_action_required_message }, "message" do
        described_class.perform_now(bank_connection.id)
      end
    end
  end

  test "clears user_action_required_message on successful update" do
    @bank_connection = bank_connections(:capital_one)

    stub_plaid_methods do
      assert_change -> { bank_connection.reload.user_action_required? }, false do
        described_class.perform_now(bank_connection.id)
      end
    end
  end

  def fake_plaid_institution
    {
      "institution" => {
        "credentials" => [
          { "label" => "Username", "name" => "username", "type" => "text" },
          { "label" => "Password", "name" => "password", "type" => "password" },
        ],
        "has_mfa" => true,
        "institution_id" => "ins_1",
        "mfa" => ["code", "questions(5)"],
        "name" => "Cool Bank",
        "products" => %w(auth balance transactions credit_details income identify),
      },
      "request_id" => "req2",
    }
  end

  def fake_plaid_item
    {
      "item" => {
        "available_products" => %w(auth balance credit_details identity income),
        "billed_products" => ["transactions"],
        "error" => nil,
        "institution_id" => fake_plaid_institution["institution"]["institution_id"],
        "item_id" => "item_id",
        "webhook" => "",
      },
      "request_id" => "req3",
    }
  end

  def fake_plaid_accounts
    {
      "accounts" => [
        {
          "account_id" => "ac_1",
          "balances" => {
            "available" => 11_120.94,
            "current" => 11_132.02,
            "limit" => nil,
          },
          "mask" => "0000",
          "name" => "Regular Savings",
          "official_name" => "Plaid Gold Standard 0% Interest Checking",
          "subtype" => "checking",
          "type" => "depository",
        },
        {
          "account_id" => "ac_2",
          "balances" => {
            "available" => 1000,
            "current" => 40,
            "limit" => nil,
          },
          "mask" => "1111",
          "name" => "Super Fancy Credit",
          "official_name" => "Plaid Silver Standard 0.1% Interest Saving",
          "subtype" => "savings",
          "type" => "credit",
        },
      ],
      "item" => fake_plaid_item["item"],
      "request_id" => "req1",
    }
  end

  def fake_plaid_transactions
    {
      "accounts" => fake_plaid_accounts["accounts"],
      "item" => fake_plaid_item["item"],
      "request_id" => "req4",
      "total_transactions" => 4,
      "transactions" => [
        {
          "account_id" => fake_plaid_accounts["accounts"][1]["account_id"],
          "account_owner" => nil,
          "amount" => 120.4,
          "category" => ["Travel", "Airlines and Aviation Services"],
          "category_id" => "22001000",
          "date" => "2016-10-10",
          "location" => {
            "address" => nil,
            "city" => nil,
            "lat" => nil,
            "lon" => nil,
            "state" => nil,
            "store_number" => nil,
            "zip" => nil,
          },
          "name" => "WAL-MART 999#33",
          "payment_meta" => {
            "by_order_of" => nil,
            "payee" => nil,
            "payer" => nil,
            "payment_method" => nil,
            "payment_processor" => nil,
            "ppd_id" => nil,
            "reason" => nil,
            "reference_number" => nil,
          },
          "pending" => false,
          "pending_transaction_id" => nil,
          "transaction_id" => "tr_1",
          "transaction_type" => "special",
        },
        {
          "account_id" => fake_plaid_accounts["accounts"][0]["account_id"],
          "account_owner" => nil,
          "amount" => -900,
          "category" => nil,
          "category_id" => nil,
          "date" => "2016-10-12",
          "location" => {
            "address" => nil,
            "city" => nil,
            "lat" => nil,
            "lon" => nil,
            "state" => nil,
            "store_number" => nil,
            "zip" => nil,
          },
          "name" => "DIRECT DEPOSIT",
          "payment_meta" => {
            "by_order_of" => nil,
            "payee" => nil,
            "payer" => nil,
            "payment_method" => nil,
            "payment_processor" => nil,
            "ppd_id" => nil,
            "reason" => nil,
            "reference_number" => nil,
          },
          "pending" => false,
          "pending_transaction_id" => nil,
          "transaction_id" => "tr_2",
          "transaction_type" => "unresolved",
        },
        {
          "account_id" => fake_plaid_accounts["accounts"][0]["account_id"],
          "account_owner" => nil,
          "amount" => 50,
          "category" => nil,
          "category_id" => nil,
          "date" => "2016-11-11",
          "location" => {
            "address" => nil,
            "city" => nil,
            "lat" => nil,
            "lon" => nil,
            "state" => nil,
            "store_number" => nil,
            "zip" => nil,
          },
          "name" => "MADEWELL #1234",
          "payment_meta" => {
            "by_order_of" => nil,
            "payee" => nil,
            "payer" => nil,
            "payment_method" => nil,
            "payment_processor" => nil,
            "ppd_id" => nil,
            "reason" => nil,
            "reference_number" => nil,
          },
          "pending" => true,
          "pending_transaction_id" => nil,
          "transaction_id" => "tr_3",
          "transaction_type" => "unresolved",
        },
      ],
    }
  end

  def fake_plaid_transactions_page_2
    {
      "accounts" => fake_plaid_accounts["accounts"],
      "item" => fake_plaid_item["item"],
      "request_id" => "req5",
      "total_transactions" => 4,
      "transactions" => [
        {
          "account_id" => fake_plaid_accounts["accounts"][1]["account_id"],
          "account_owner" => nil,
          "amount" => 40,
          "category" => nil,
          "category_id" => nil,
          "date" => "2016-11-11",
          "location" => {
            "address" => nil,
            "city" => nil,
            "lat" => nil,
            "lon" => nil,
            "state" => nil,
            "store_number" => nil,
            "zip" => nil,
          },
          "name" => "UBER SF****POOL",
          "payment_meta" => {
            "by_order_of" => nil,
            "payee" => nil,
            "payer" => nil,
            "payment_method" => nil,
            "payment_processor" => nil,
            "ppd_id" => nil,
            "reason" => nil,
            "reference_number" => nil,
          },
          "pending" => false,
          "pending_transaction_id" => nil,
          "transaction_id" => "tr_4",
          "transaction_type" => "unresolved",
        },
      ],
    }
  end

  def stub_plaid_methods
    Plaid.client.item.expect(:get, fake_plaid_item, [bank_connection.plaid_access_token]) do
      Plaid.client.institutions.expect(:get_by_id, fake_plaid_institution, [fake_plaid_institution["institution"]["institution_id"]]) do
        stub_plaid_accounts do
          transactions_mock = MiniTest::Mock.new
          transactions_mock.expect(:call, fake_plaid_transactions, [bank_connection.plaid_access_token, Date, Date, offset: 0])
          transactions_mock.expect(:call, fake_plaid_transactions_page_2, [bank_connection.plaid_access_token, Date, Date, offset: 3])

          Plaid.client.transactions.stub(:get, transactions_mock) do
            yield
          end

          transactions_mock.verify
        end
      end
    end
  end

  def stub_plaid_accounts
    Plaid.client.accounts.expect(:get, fake_plaid_accounts, [bank_connection.plaid_access_token]) do
      yield
    end
  end
end
