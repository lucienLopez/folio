class CreateStockSnapshots < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_snapshots do |t|
      t.references :stock, null: false, foreign_key: true
      t.text :response_payload
      t.time :snapshot_at, null: false
      t.decimal :previous_close_price, precision: 10, scale: 2
      t.string :currency, limit: 3

      t.timestamps
    end
  end
end
