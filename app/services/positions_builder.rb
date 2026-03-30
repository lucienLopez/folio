# frozen_string_literal: true

class PositionsBuilder < ApplicationService
  def call
    Security
      .joins(:orders)
      .group("securities.id")
      .select(
        "securities.*",
        "SUM(CASE WHEN orders.operation_type = 'buy' THEN orders.shares ELSE -orders.shares END) AS net_shares",
        "SUM(CASE WHEN orders.operation_type = 'buy' THEN orders.total_amount ELSE 0 END) /
           NULLIF(SUM(CASE WHEN orders.operation_type = 'buy' THEN orders.shares ELSE 0 END), 0) AS avg_buy_price_eur",
        "SUM(CASE WHEN orders.operation_type = 'buy' THEN orders.total_amount " \
        "ELSE -orders.total_amount END) AS total_invested"
      )
      .having("SUM(CASE WHEN orders.operation_type = 'buy' THEN orders.shares ELSE -orders.shares END) > 0")
      .order("total_invested DESC")
  end
end
