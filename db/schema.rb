# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_09_135911) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "merchants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.integer "status"
    t.decimal "total_transaction_sum", default: "0.0"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_merchants_on_user_id"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.string "customer_email", null: false
    t.string "customer_phone"
    t.bigint "merchant_id", null: false
    t.uuid "reference_transaction_id"
    t.integer "status", default: 3, null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_transactions_on_merchant_id"
    t.index ["reference_transaction_id"], name: "index_transactions_on_reference_transaction_id"
    t.index ["status"], name: "index_transactions_on_status"
    t.index ["type"], name: "index_transactions_on_type"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti"
    t.integer "role", default: 0
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
  end

  add_foreign_key "merchants", "users"
  add_foreign_key "transactions", "merchants"
  add_foreign_key "transactions", "transactions", column: "reference_transaction_id"
end
