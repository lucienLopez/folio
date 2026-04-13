# frozen_string_literal: true

class HistoricalSnapshotImporter < ApplicationService
  def initialize(since: nil)
    earliest = Order.minimum("DATE(executed_at)")
    @since = since || (earliest ? Date.parse(earliest.to_s) : Time.zone.today)
  end

  def call
    securities = Security.where.not(symbol: nil)
    period1 = @since.to_time.to_i
    period2 = Date.yesterday.to_time.to_i

    if period1 >= period2
      Rails.logger.debug "No historical range to import (since=#{@since})."
      return
    end

    Rails.logger.debug "Importing history for #{securities.count} securities from #{@since} to #{Date.yesterday}..."

    # Reuse a single query instance (shares the Yahoo Finance session/cookie)
    query = BasicYahooFinance::Query.new

    securities.find_each do |security|
      import_security(security, query, period1, period2)
      sleep 1
    end

    Rails.logger.debug "\nDone importing snapshots. Total SecuritySnapshots: #{SecuritySnapshot.count}"
  end

  private

  def import_security(security, query, period1, period2)
    existing_dates = SecuritySnapshot
                     .where(security_id: security.id)
                     .pluck("DATE(created_at)")
                     .map { |d| d.is_a?(Date) ? d : Date.parse(d.to_s) }
                     .to_set

    result = query.history(security.symbol, period1, period2, "1d")
    data = result[security.symbol]

    unless data.is_a?(Hash) && data.dig("chart", "result")
      Rails.logger.debug "  #{security.symbol}: no data returned"
      return
    end

    chart_result = data.dig("chart", "result", 0)
    return unless chart_result

    timestamps = chart_result["timestamp"] || []
    closes     = chart_result.dig("indicators", "quote", 0, "close") || []
    currency   = chart_result.dig("meta", "currency") || "EUR"

    records = []
    timestamps.each_with_index do |ts, i|
      close = closes[i]
      next unless close

      date = Time.at(ts).utc.to_date
      next if existing_dates.include?(date)
      next if date >= Time.zone.today

      ts_at_noon = Time.utc(date.year, date.month, date.day, 12, 0, 0)
      records << {
        security_id: security.id,
        snapshot_at: "12:00:00",
        previous_close_price: close.round(4),
        currency: currency,
        response_payload: nil,
        created_at: ts_at_noon,
        updated_at: ts_at_noon
      }
    end

    if records.any?
      SecuritySnapshot.insert_all(records) # rubocop:disable Rails/SkipsModelValidations
      Rails.logger.debug "."
    else
      Rails.logger.debug "s" # skipped (already up to date)
    end
  rescue StandardError => e
    Rails.logger.debug "!"
    Rails.logger.error("HistoricalSnapshotImporter failed for #{security.symbol}: #{e.message}")
  end
end
