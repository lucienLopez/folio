# frozen_string_literal: true

class ExchangeRate < ApplicationRecord
  validates :date, :currency, :rate, presence: true
  validates :currency, uniqueness: { scope: :date }
end
