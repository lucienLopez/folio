# frozen_string_literal: true

class Order < ApplicationRecord
  OPERATION_TYPES = [
    BUY = 'buy',
    SELL = 'sell'
  ].freeze

  belongs_to :security

  scope :buys, -> { where(operation_type: BUY) }
  scope :sells, -> { where(operation_type: SELL) }

  def fees
    total_amount - (shares * price_eur)
  end
end
