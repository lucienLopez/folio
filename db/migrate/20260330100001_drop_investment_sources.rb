# frozen_string_literal: true

class DropInvestmentSources < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :orders, :investment_sources
    remove_reference :orders, :investment_source
    drop_table :investment_sources do |t|
      t.string :name, null: false
      t.string :url
      t.timestamps
    end
  end
end
