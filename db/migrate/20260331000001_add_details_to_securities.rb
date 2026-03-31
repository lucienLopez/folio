# frozen_string_literal: true

class AddDetailsToSecurities < ActiveRecord::Migration[7.2]
  def change
    add_column :securities, :sector, :string
    add_column :securities, :industry, :string
    add_column :securities, :country, :string
    add_column :securities, :expense_ratio, :decimal, precision: 8, scale: 4
  end
end
