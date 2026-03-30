# frozen_string_literal: true

class CreateExchangeRates < ActiveRecord::Migration[7.1]
  def change
    create_table :exchange_rates do |t|
      t.date :date, null: false
      t.string :currency, null: false
      t.decimal :rate, precision: 10, scale: 6, null: false
      t.timestamps
    end

    add_index :exchange_rates, [:date, :currency], unique: true
  end
end
