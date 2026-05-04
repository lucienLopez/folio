# frozen_string_literal: true

class SecuritySnapshotTaker < ApplicationService
  def self.take_all_snapshots
    Security.where.not(symbol: nil).find_each do |security|
      SecuritySnapshotTaker.call(security)
      sleep 1 # Not sure if there are rate limits
    end
    PortfolioSnapshotRecorder.call(date: Time.zone.today)
  end

  def initialize(security)
    @security = security
  end

  def call
    query = BasicYahooFinance::Query.new
    quote = query.quotes(@security.symbol)
    payload = quote&.[](@security.symbol)

    unless payload
      Rails.logger.warn("SecuritySnapshotTaker: no quote data for #{@security.symbol}, skipping")
      return
    end

    SecuritySnapshot.create!(
      security: @security,
      response_payload: quote.to_json,
      snapshot_at: Time.current,
      previous_close_price: payload['regularMarketPreviousClose'],
      currency: payload['currency']
    )
  rescue StandardError => e
    Rails.logger.error("SecuritySnapshotTaker failed for #{@security.symbol}: #{e.message}")
  end
end
