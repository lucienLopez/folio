# frozen_string_literal: true

module CurrencyParser
  SYMBOL_TO_CURRENCY = {
    '€' => 'EUR',
    '$' => 'USD',
    '£' => 'GBP',
    'CHF' => 'CHF',
    'Fr.' => 'CHF',
    'zł' => 'PLN',
    'Ft' => 'HUF',
    'NOK' => 'NOK',
    'SEK' => 'SEK',
    'DKK' => 'DKK',
    'kr' => nil # ambiguous, resolved via place
  }.freeze

  KR_PLACE_TO_CURRENCY = {
    'OSLO' => 'NOK',
    'STOCKHOLM' => 'SEK',
    'COPENHAGUE' => 'DKK'
  }.freeze

  def self.parse(price_string, place = nil)
    symbol = price_string.to_s.gsub(/[\d,.\s]/, '').strip
    currency = SYMBOL_TO_CURRENCY[symbol]

    if currency.nil? && symbol == 'kr'
      KR_PLACE_TO_CURRENCY.each do |keyword, kr_currency|
        return kr_currency if place.to_s.upcase.include?(keyword)
      end
    end

    currency || 'EUR'
  end
end
