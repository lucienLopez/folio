# frozen_string_literal: true

class RenameStockToSecurityAndAddKind < ActiveRecord::Migration[7.1]
  def change
    rename_table :stocks, :securities
    rename_table :stock_snapshots, :security_snapshots

    rename_column :investments, :stock_id, :security_id
    rename_column :security_snapshots, :stock_id, :security_id

    add_column :securities, :kind, :string
  end
end
