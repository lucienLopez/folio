# frozen_string_literal: true

class CreateSleeves < ActiveRecord::Migration[7.2]
  def change
    create_table :sleeves do |t|
      t.string :name, null: false
      t.decimal :target_weight, precision: 5, scale: 2, null: false

      t.timestamps
    end

    add_reference :securities, :sleeve, foreign_key: true
  end
end
