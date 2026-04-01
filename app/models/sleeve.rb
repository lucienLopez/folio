# frozen_string_literal: true

class Sleeve < ApplicationRecord
  has_many :securities, dependent: :nullify

  validates :name, presence: true
  validates :target_weight, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
end
