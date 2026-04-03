# frozen_string_literal: true

class AddTargetWeightToSecurities < ActiveRecord::Migration[7.2]
  def change
    add_column :securities, :target_weight, :decimal, precision: 5, scale: 2
  end
end
