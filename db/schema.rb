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

  create_table "accounts", id: :bigserial, force: :cascade do |t|
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "time_zone",  limit: 255
  end

  create_table "bank_accounts", id: :bigserial, force: :cascade do |t|
    t.bigint   "account_id",                     null: false
    t.string   "name",               limit: 255, null: false
    t.string   "remote_identifier",  limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.bigint   "type",                           null: false
    t.bigint   "bank_connection_id"
    t.index ["account_id"], name: "index_bank_accounts_on_account_id", using: :btree
    t.index ["bank_connection_id"], name: "index_bank_accounts_on_bank_connection_id", using: :btree
  end

  create_table "bank_connections", id: :bigserial, force: :cascade do |t|
    t.string   "plaid_access_token",        limit: 255,                 null: false
    t.bigint   "account_id",                                            null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "institution_name",          limit: 255
    t.datetime "refreshed_at"
    t.boolean  "refreshing",                            default: false, null: false
    t.datetime "successfully_refreshed_at"
    t.index ["account_id"], name: "index_bank_connections_on_account_id", using: :btree
  end

  create_table "bank_transactions", id: :bigserial, force: :cascade do |t|
    t.bigint   "bank_account_id",                               null: false
    t.bigint   "account_id",                                    null: false
    t.string   "payee",             limit: 255,                 null: false
    t.datetime "posted_at",                                     null: false
    t.bigint   "amount_cents",                  default: 0,     null: false
    t.string   "amount_currency",   limit: 255, default: "USD", null: false
    t.string   "memo",              limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "remote_identifier", limit: 255
    t.bigint   "source",                        default: 0,     null: false
    t.index ["account_id"], name: "index_bank_transactions_on_account_id", using: :btree
    t.index ["bank_account_id"], name: "index_bank_transactions_on_bank_account_id", using: :btree
    t.index ["remote_identifier"], name: "index_bank_transactions_on_remote_identifier", unique: true, using: :btree
  end

  create_table "designations", id: :bigserial, force: :cascade do |t|
    t.bigint   "account_id",                                      null: false
    t.bigint   "bank_transaction_id",                             null: false
    t.bigint   "envelope_id",                                     null: false
    t.bigint   "amount_cents",                    default: 0,     null: false
    t.string   "amount_currency",     limit: 255, default: "USD", null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.index ["account_id"], name: "index_designations_on_account_id", using: :btree
    t.index ["bank_transaction_id"], name: "index_designations_on_bank_transaction_id", using: :btree
    t.index ["envelope_id"], name: "index_designations_on_envelope_id", using: :btree
  end

  create_table "envelope_groups", id: :bigserial, force: :cascade do |t|
    t.bigint   "account_id",             null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["account_id"], name: "index_envelope_groups_on_account_id", using: :btree
  end

  create_table "envelopes", id: :bigserial, force: :cascade do |t|
    t.bigint   "account_id",                    null: false
    t.bigint   "envelope_group_id",             null: false
    t.string   "name",              limit: 255, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "archived_at"
    t.index ["account_id"], name: "index_envelopes_on_account_id", using: :btree
    t.index ["envelope_group_id"], name: "index_envelopes_on_envelope_group_id", using: :btree
  end

  create_table "users", id: :bigserial, force: :cascade do |t|
    t.bigint   "account_id",                  null: false
    t.string   "username",        limit: 255, null: false
    t.string   "password_digest", limit: 255, null: false
    t.string   "auth_token",      limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["account_id"], name: "index_users_on_account_id", using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "bank_accounts", "accounts", on_update: :restrict, on_delete: :restrict
  add_foreign_key "bank_accounts", "bank_connections", on_update: :restrict, on_delete: :restrict
  add_foreign_key "bank_connections", "accounts", on_update: :restrict, on_delete: :restrict
  add_foreign_key "bank_transactions", "accounts", on_update: :restrict, on_delete: :restrict
  add_foreign_key "bank_transactions", "bank_accounts", on_update: :restrict, on_delete: :restrict
  add_foreign_key "designations", "accounts", on_update: :restrict, on_delete: :restrict
  add_foreign_key "designations", "bank_transactions", on_update: :restrict, on_delete: :restrict
  add_foreign_key "designations", "envelopes", on_update: :restrict, on_delete: :restrict
  add_foreign_key "envelope_groups", "accounts", on_update: :restrict, on_delete: :restrict
  add_foreign_key "envelopes", "accounts", on_update: :restrict, on_delete: :restrict
  add_foreign_key "envelopes", "envelope_groups", on_update: :restrict, on_delete: :restrict
  add_foreign_key "users", "accounts", on_update: :restrict, on_delete: :restrict
end
