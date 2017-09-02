# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170831185651) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "time_zone"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.integer  "account_id",         null: false
    t.string   "name",               null: false
    t.string   "remote_identifier"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "type",               null: false
    t.integer  "bank_connection_id"
    t.index ["account_id"], name: "index_bank_accounts_on_account_id", using: :btree
    t.index ["bank_connection_id"], name: "index_bank_accounts_on_bank_connection_id", using: :btree
  end

  create_table "bank_connections", force: :cascade do |t|
    t.string   "plaid_access_token",                        null: false
    t.integer  "account_id",                                null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "institution_name"
    t.datetime "refreshed_at"
    t.boolean  "refreshing",                default: false, null: false
    t.datetime "successfully_refreshed_at"
    t.index ["account_id"], name: "index_bank_connections_on_account_id", using: :btree
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.integer  "bank_account_id",                   null: false
    t.integer  "account_id",                        null: false
    t.string   "payee",                             null: false
    t.datetime "posted_at",                         null: false
    t.integer  "amount_cents",      default: 0,     null: false
    t.string   "amount_currency",   default: "USD", null: false
    t.string   "memo"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "remote_identifier"
    t.integer  "source",            default: 0,     null: false
    t.index ["account_id"], name: "index_bank_transactions_on_account_id", using: :btree
    t.index ["bank_account_id"], name: "index_bank_transactions_on_bank_account_id", using: :btree
    t.index ["remote_identifier"], name: "index_bank_transactions_on_remote_identifier", unique: true, using: :btree
  end

  create_table "designations", force: :cascade do |t|
    t.integer  "account_id",                          null: false
    t.integer  "bank_transaction_id",                 null: false
    t.integer  "envelope_id",                         null: false
    t.integer  "amount_cents",        default: 0,     null: false
    t.string   "amount_currency",     default: "USD", null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["account_id"], name: "index_designations_on_account_id", using: :btree
    t.index ["bank_transaction_id"], name: "index_designations_on_bank_transaction_id", using: :btree
    t.index ["envelope_id"], name: "index_designations_on_envelope_id", using: :btree
  end

  create_table "envelope_groups", force: :cascade do |t|
    t.integer  "account_id", null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_envelope_groups_on_account_id", using: :btree
  end

  create_table "envelopes", force: :cascade do |t|
    t.integer  "account_id",        null: false
    t.integer  "envelope_group_id", null: false
    t.string   "name",              null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["account_id"], name: "index_envelopes_on_account_id", using: :btree
    t.index ["envelope_group_id"], name: "index_envelopes_on_envelope_group_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.integer  "account_id",      null: false
    t.string   "username",        null: false
    t.string   "password_digest", null: false
    t.string   "auth_token",      null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["account_id"], name: "index_users_on_account_id", using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "bank_accounts", "accounts"
  add_foreign_key "bank_accounts", "bank_connections"
  add_foreign_key "bank_connections", "accounts"
  add_foreign_key "bank_transactions", "accounts"
  add_foreign_key "bank_transactions", "bank_accounts"
  add_foreign_key "designations", "accounts"
  add_foreign_key "designations", "bank_transactions"
  add_foreign_key "designations", "envelopes"
  add_foreign_key "envelope_groups", "accounts"
  add_foreign_key "envelopes", "accounts"
  add_foreign_key "envelopes", "envelope_groups"
  add_foreign_key "users", "accounts"
end
