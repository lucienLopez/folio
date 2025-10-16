class CreateBasicModels < ActiveRecord::Migration[7.1]
  def change
    create_table :stocks do |t|
      t.string :isin, null: false, index: { unique: true }
      t.string :name, null: false
      t.timestamps
    end

    create_table :investment_sources do |t|
      t.string :name, null: false
      t.string :url
      t.timestamps
    end

    create_table :investments do |t|
      t.references :stock, null: false, foreign_key: true
      t.references :investment_source, null: true, foreign_key: true
      t.integer :shares, null: false
      t.decimal :purchase_price, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.datetime :purchased_at, null: false
      t.string :reference_number
      t.string :notes
      t.timestamps
    end
  end
end
