class StockSnapshotTaker < ApplicationService
  def self.take_all_snapshots
    Stock.where.not(symbol: nil).find_each do |stock|
      StockSnapshotTaker.call(stock)
      sleep 1 # Not sure if there are rate limits
    end
  end

  def initialize(stock)
    @stock = stock
  end

  def call
    query = BasicYahooFinance::Query.new
    quote = query.quotes(@stock.symbol)

    unless quote
      # TODO error handling / logging
    end

    payload = quote[@stock.symbol]

    StockSnapshot.create!(
      stock: @stock,
      response_payload: quote.to_json,
      snapshot_at: Time.current,
      previous_close_price: payload['regularMarketPreviousClose'],
      currency: payload['currency'],
    )
  end
end
