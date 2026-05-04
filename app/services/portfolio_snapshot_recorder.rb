# frozen_string_literal: true

class PortfolioSnapshotRecorder < ApplicationService
  def initialize(date: Time.zone.today)
    @date = date
  end

  def call
    # Fetch ALL securities with any order (including fully sold ones)
    all_rows = fetch_all_rows_as_of(@date)
    return if all_rows.empty?

    open_rows = all_rows.select { |r| r.net_shares.to_f > 0 }
    prices = fetch_prices(open_rows, @date)

    per_security = all_rows.filter_map do |row|
      net_shares = row.net_shares.to_f

      if net_shares > 0
        # Open position — need a market price
        price_data = prices[row.id]
        next unless price_data

        price_eur = CurrencyConverter.call(
          amount: price_data[:price],
          from: price_data[:currency],
          date: @date
        )
        unrealized = net_shares * price_eur
      else
        # Fully sold — no current price needed
        unrealized = 0
      end

      {
        sleeve_id: row.sleeve_id,
        # Unrealized market value of remaining shares + proceeds already received from sales
        value_eur: unrealized + row.sell_total.to_f,
        # Total capital ever deployed (all buys), regardless of whether still held
        invested_eur: row.buy_total.to_f
      }
    end

    return if per_security.empty?

    upsert_snapshot(nil, per_security.sum { |e| e[:value_eur] }, per_security.sum { |e| e[:invested_eur] })

    per_security.group_by { |e| e[:sleeve_id] }.each do |sleeve_id, entries|
      next if sleeve_id.nil?

      upsert_snapshot(sleeve_id, entries.sum { |e| e[:value_eur] }, entries.sum { |e| e[:invested_eur] })
    end
  end

  private

  def fetch_all_rows_as_of(date)
    Security
      .joins(:orders)
      .merge(Order.where("DATE(executed_at) <= ?", date))
      .group("securities.id")
      .select(
        "securities.*",
        "SUM(CASE WHEN orders.operation_type = 'buy' THEN orders.shares ELSE -orders.shares END) AS net_shares",
        "SUM(CASE WHEN orders.operation_type = 'buy' THEN orders.total_amount ELSE 0 END) AS buy_total",
        "SUM(CASE WHEN orders.operation_type = 'sell' THEN orders.total_amount ELSE 0 END) AS sell_total"
      )
  end

  def fetch_prices(rows, date)
    return {} if rows.empty?

    if date == Time.zone.today
      symbols = rows.filter_map(&:symbol)
      return {} if symbols.empty?

      quotes = BasicYahooFinance::Query.new.quotes(symbols)
      rows.each_with_object({}) do |row, hash|
        next unless row.symbol

        q = quotes[row.symbol]
        next unless q

        hash[row.id] = { price: q['regularMarketPrice'], currency: q['currency'] || 'EUR' }
      end
    else
      # Use the most recent available price on or before the date (handles holidays/missing days)
      SecuritySnapshot
        .where(security_id: rows.map(&:id))
        .where("DATE(created_at) <= ?", date)
        .where.not(previous_close_price: nil)
        .order(created_at: :desc)
        .each_with_object({}) do |snap, hash|
          hash[snap.security_id] ||= { price: snap.previous_close_price, currency: snap.currency || 'EUR' }
        end
    end
  end

  def upsert_snapshot(sleeve_id, value_eur, invested_eur)
    snap = PortfolioSnapshot.find_or_initialize_by(date: @date, sleeve_id: sleeve_id)
    snap.value_eur = value_eur.round(2)
    snap.invested_eur = invested_eur.round(2)
    snap.save!
  end
end
