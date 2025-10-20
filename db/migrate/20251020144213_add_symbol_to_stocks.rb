class AddSymbolToStocks < ActiveRecord::Migration[7.1]
  def change
    add_column :stocks, :symbol, :string
  end
end
