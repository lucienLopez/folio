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

ActiveRecord::Schema[7.2].define(version: 2026_03_31_000001) do
  create_table "exchange_rates", force: :cascade do |t|
    t.date "date", null: false
    t.string "currency", null: false
    t.decimal "rate", precision: 10, scale: 6, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "currency"], name: "index_exchange_rates_on_date_and_currency", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.integer "security_id", null: false
    t.integer "shares", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.datetime "executed_at", null: false
    t.string "reference_number"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency", default: "EUR", null: false
    t.decimal "price_eur", precision: 10, scale: 2
    t.string "operation_type", default: "buy", null: false
    t.index ["security_id"], name: "index_orders_on_security_id"
  end

  create_table "securities", force: :cascade do |t|
    t.string "isin", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "symbol"
    t.string "kind"
    t.string "sector"
    t.string "industry"
    t.string "country"
    t.decimal "expense_ratio", precision: 8, scale: 4
    t.index ["isin"], name: "index_securities_on_isin", unique: true
  end

  create_table "security_snapshots", force: :cascade do |t|
    t.integer "security_id", null: false
    t.text "response_payload"
    t.time "snapshot_at", null: false
    t.decimal "previous_close_price", precision: 10, scale: 2
    t.string "currency", limit: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["security_id"], name: "index_security_snapshots_on_security_id"
  end

  add_foreign_key "orders", "securities"
  add_foreign_key "security_snapshots", "securities"
end
