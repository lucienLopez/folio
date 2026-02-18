# frozen_string_literal: true

class SecuritySnapshotTaker < ApplicationService
  def self.take_all_snapshots
    Security.where.not(symbol: nil).find_each do |security|
      SecuritySnapshotTaker.call(security)
      sleep 1 # Not sure if there are rate limits
    end
  end

  def initialize(security)
    @security = security
  end

  def call
    query = BasicYahooFinance::Query.new
    quote = query.quotes(@security.symbol)

    unless quote
      # TODO: error handling / logging
    end

    payload = quote[@security.symbol]

    SecuritySnapshot.create!(
      security: @security,
      response_payload: quote.to_json,
      snapshot_at: Time.current,
      previous_close_price: payload['regularMarketPreviousClose'],
      currency: payload['currency']
    )
  end
end
