# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    positions = PositionsBuilder.call
    @total_value = positions.sum { |p| p.current_value || 0 }
    @sleeves = Sleeve.all.to_a
    @current_sleeve = @sleeves.find { |s| s.id.to_s == params[:sleeve_id] }

    @sleeve_weights = @sleeves.index_with do |sleeve|
      value = positions.select { |p| p.sleeve_name == sleeve.name }.sum { |p| p.current_value || 0 }
      @total_value.positive? ? (value / @total_value * 100).round(1) : 0
    end

    scoped = @current_sleeve ? positions.select { |p| p.sleeve_name == @current_sleeve.name } : positions
    @scoped_positions = scoped
    stocks = scoped.select { |p| p.kind == Security::STOCK }

    @by_sector = group_by_value(stocks, :sector)
    @by_country = group_by_value(stocks, :country)
    @by_kind = group_by_value(scoped, :kind)
    @scoped_value = scoped.sum { |p| p.current_value || 0 }
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
