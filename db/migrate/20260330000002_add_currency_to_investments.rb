# frozen_string_literal: true

class AddCurrencyToInvestments < ActiveRecord::Migration[7.1]
  def change
    add_column :investments, :purchase_currency, :string, null: false, default: 'EUR'
    add_column :investments, :purchase_price_eur, :decimal, precision: 10, scale: 2
  end
end
