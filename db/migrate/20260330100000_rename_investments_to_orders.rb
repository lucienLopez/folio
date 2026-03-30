# frozen_string_literal: true

class RenameInvestmentsToOrders < ActiveRecord::Migration[7.2]
  def change
    rename_table :investments, :orders

    rename_column :orders, :purchase_price, :price
    rename_column :orders, :purchase_currency, :currency
    rename_column :orders, :purchase_price_eur, :price_eur
    rename_column :orders, :purchased_at, :executed_at
    rename_column :orders, :total_price, :total_amount

    add_column :orders, :operation_type, :string, null: false, default: 'buy'
  end
end
