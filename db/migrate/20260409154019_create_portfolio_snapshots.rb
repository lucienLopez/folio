# frozen_string_literal: true

class CreatePortfolioSnapshots < ActiveRecord::Migration[7.2]
  def change
    create_table :portfolio_snapshots do |t|
      t.date    :date, null: false
      t.integer :sleeve_id
      t.decimal :value_eur,    precision: 12, scale: 2, null: false
      t.decimal :invested_eur, precision: 12, scale: 2, null: false
      t.timestamps
    end

    add_index :portfolio_snapshots, %i[date sleeve_id], unique: true
    add_foreign_key :portfolio_snapshots, :sleeves, column: :sleeve_id
  end
end
