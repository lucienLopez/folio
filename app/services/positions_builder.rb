# frozen_string_literal: true

class PositionsBuilder < ApplicationService
  Position = Struct.new(
    :name, :kind, :isin, :symbol,
    :net_shares, :avg_buy_price_eur, :total_invested,
    :current_price, :current_price_eur,
    :previous_close_price, :previous_close_price_eur,
    :sector, :country, :sleeve_name,
    :target_weight, :sleeve_weight,
    keyword_init: true
  ) do
    def current_value
      return nil unless current_price_eur

      net_shares * current_price_eur
    end

    def previous_close_value
      return nil unless previous_close_price_eur

      net_shares * previous_close_price_eur
    end

    def day_change
      return nil unless current_value && previous_close_value

      current_value - previous_close_value
    end

    def day_change_pct
      return nil unless day_change && previous_close_value&.positive?

      day_change / previous_close_value * 100
    end

    def gain
      return nil unless current_value

      current_value - total_invested
    end

    def gain_pct
      return nil unless gain && total_invested.positive?

      gain / total_invested * 100
    end
  end

  def call
    rows = fetch_rows
    prices = fetch_prices(rows.filter_map(&:symbol))
    sleeves = Sleeve.all.index_by(&:id)

    rows.map do |row|
      payload = prices[row.symbol]
      current_price = payload&.[]('regularMarketPrice')
      previous_close_price = payload&.[]('regularMarketPreviousClose')
      current_currency = payload&.[]('currency') || 'EUR'
      current_price_eur = current_price && CurrencyConverter.call(
        amount: current_price,
        from: current_currency,
        date: Time.zone.today
      )
      previous_close_price_eur = previous_close_price && CurrencyConverter.call(
        amount: previous_close_price,
        from: current_currency,
        date: Time.zone.today
      )

      Position.new(
        name: row.name,
        kind: row.kind,
        isin: row.isin,
        symbol: row.symbol,
        net_shares: row.net_shares,
        avg_buy_price_eur: row.avg_buy_price_eur,
        total_invested: row.total_invested,
        current_price: current_price,
        current_price_eur: current_price_eur,
        previous_close_price: previous_close_price,
        previous_close_price_eur: previous_close_price_eur,
        sector: row.sector,
        country: row.country,
        sleeve_name: sleeves[row.sleeve_id]&.name,
        target_weight: row.target_weight
      )
    end.tap { |positions| assign_sleeve_weights(positions) }
  end

  private

  def fetch_rows
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

  def assign_sleeve_weights(positions)
    sleeve_totals = positions.group_by(&:sleeve_name).transform_values do |sleeve_positions|
      sleeve_positions.sum { |p| p.current_value || 0 }
    end

    positions.each do |position|
      total = sleeve_totals[position.sleeve_name]
      next unless total&.positive? && position.current_value

      position.sleeve_weight = position.current_value / total * 100
    end
  end

  def fetch_prices(symbols)
    return {} if symbols.empty?

    BasicYahooFinance::Query.new.quotes(symbols)
  end
end
