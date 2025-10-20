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

ActiveRecord::Schema[7.1].define(version: 2025_10_20_150722) do
  create_table "investment_sources", force: :cascade do |t|
    t.string "name", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "investments", force: :cascade do |t|
    t.integer "stock_id", null: false
    t.integer "investment_source_id"
    t.integer "shares", null: false
    t.decimal "purchase_price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.datetime "purchased_at", null: false
    t.string "reference_number"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["investment_source_id"], name: "index_investments_on_investment_source_id"
    t.index ["stock_id"], name: "index_investments_on_stock_id"
  end

  create_table "stock_snapshots", force: :cascade do |t|
    t.integer "stock_id", null: false
    t.text "response_payload"
    t.time "snapshot_at", null: false
    t.decimal "previous_close_price", precision: 10, scale: 2
    t.string "currency", limit: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_stock_snapshots_on_stock_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "isin", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "symbol"
    t.index ["isin"], name: "index_stocks_on_isin", unique: true
  end

  add_foreign_key "investments", "investment_sources"
  add_foreign_key "investments", "stocks"
  add_foreign_key "stock_snapshots", "stocks"
end
