# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    positions = PositionsBuilder.call
    @total_value = positions.sum { |p| p.current_value || 0 }

    stocks = positions.select { |p| p.kind == Security::STOCK }

    @by_sector = group_by_value(stocks, :sector)
    @by_country = group_by_value(stocks, :country)
    @by_kind = group_by_value(positions, :kind)
  end

  private

  def group_by_value(positions, attribute)
    positions
      .group_by { |p| p.public_send(attribute).presence || "Unknown" }
      .transform_values { |group| group.sum { |p| p.current_value || p.total_invested }.round(2) }
      .sort_by { |_, v| -v }
      .to_h
  end
end
