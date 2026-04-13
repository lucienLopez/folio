# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    load_performance_chart_data

    positions = PositionsBuilder.call
    @total_value = positions.sum { |p| p.current_value || 0 }
    @sleeves = Sleeve.all.to_a
    @current_sleeve = @sleeves.find { |s| s.id.to_s == params[:sleeve_id] }

    @sleeve_weights = @sleeves.index_with do |sleeve|
      value = positions.select { |p| p.sleeve_name == sleeve.name }.sum { |p| p.current_value || 0 }
      @total_value.positive? ? (value / @total_value * 100).round(1) : 0
    end

    @sleeve_day_changes = @sleeves.index_with do |sleeve|
      day_change_stats(positions.select { |p| p.sleeve_name == sleeve.name })
    end

    scoped = @current_sleeve ? positions.select { |p| p.sleeve_name == @current_sleeve.name } : positions
    @scoped_positions = scoped
    stocks = scoped.select { |p| p.kind == Security::STOCK }

    @by_sector = group_by_value(stocks, :sector)
    @by_country = group_by_value(stocks, :country)
    @by_kind = group_by_value(scoped, :kind)
    @scoped_value = scoped.sum { |p| p.current_value || 0 }
    @scoped_day_change = day_change_stats(scoped)
    @total_day_change = day_change_stats(positions)
  end

  private

  def load_performance_chart_data
    snapshots = PortfolioSnapshot.where(date: 1.year.ago.to_date..).order(:date)
    global_rows = snapshots.global.pluck(:date, :value_eur, :invested_eur)

    @chart_has_data = global_rows.any?
    return unless @chart_has_data

    @chart_global_value = global_rows.map { |d, v, _i| [fmt(d), v.to_f] }.to_h
    @chart_global_perf  = global_rows.map { |d, v, i|
      pct = i.positive? ? ((v - i) / i * 100).round(2) : 0
      [fmt(d), pct]
    }.to_h

    @chart_sleeves_value = {}
    @chart_sleeves_perf  = {}
    Sleeve.all.find_each do |sleeve|
      rows = snapshots.for_sleeve(sleeve.id).pluck(:date, :value_eur, :invested_eur)
      next if rows.empty?

      @chart_sleeves_value[sleeve.name] = rows.map { |d, v, _i| [fmt(d), v.to_f] }.to_h
      @chart_sleeves_perf[sleeve.name]  = rows.map { |d, v, i|
        pct = i.positive? ? ((v - i) / i * 100).round(2) : 0
        [fmt(d), pct]
      }.to_h
    end
  end

  def fmt(date)
    date.strftime("%d/%m/%Y")
  end

  def day_change_stats(positions)
    with_change = positions.select(&:day_change)
    return nil if with_change.empty?

    change = with_change.sum(&:day_change)
    prev_total = with_change.sum(&:previous_close_value)
    pct = prev_total.positive? ? (change / prev_total * 100).round(2) : nil
    { change: change.round(2), pct: pct }
  end

  def group_by_value(positions, attribute)
    positions
      .group_by { |p| p.public_send(attribute).presence || "Unknown" }
      .transform_values { |group| group.sum { |p| p.current_value || p.total_invested }.round(2) }
      .sort_by { |_, v| -v }
      .to_h
  end
end
