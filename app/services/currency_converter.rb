# frozen_string_literal: true

require 'net/http'
require 'json'

class CurrencyConverter < ApplicationService
  BASE_CURRENCY = 'EUR'
  FRANKFURTER_URL = 'https://api.frankfurter.app'

  def initialize(amount:, from:, date:)
    @amount = amount
    @from = from
    @date = date
  end

  def call
    return @amount if @from == BASE_CURRENCY

    rate = ExchangeRate.find_by(date: @date, currency: @from)&.rate || fetch_and_store_rate
    (@amount / rate).round(2)
  end

  private

  def fetch_and_store_rate
    uri = URI("#{FRANKFURTER_URL}/#{@date}?from=#{BASE_CURRENCY}&to=#{@from}")
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    rate = data.dig('rates', @from)

    raise "Could not fetch exchange rate for #{@from} on #{@date}" if rate.nil?

    ExchangeRate.create!(date: @date, currency: @from, rate: rate)
    rate
  end
end
