# frozen_string_literal: true

class SecurityDetailsFetcher < ApplicationService
  API_URL = "https://query1.finance.yahoo.com"
  COOKIE_URL = "https://fc.yahoo.com"
  CRUMB_URL = "#{API_URL}/v1/test/getcrumb".freeze
  USER_AGENT = BasicYahooFinance::Query::USER_AGENT

  def self.fetch_all
    Security.where.not(symbol: nil).find_each do |security|
      SecurityDetailsFetcher.call(security)
      sleep 1
    end
  end

  def initialize(security)
    @security = security
  end

  def call
    cookie = fetch_cookie
    crumb = fetch_crumb(cookie)
    data = fetch_summary(cookie, crumb)
    return unless data

    updates = extract_updates(data)
    @security.update!(updates) unless updates.empty?
  end

  private

  def fetch_cookie
    response = Net::HTTP.get_response(URI(COOKIE_URL), { "Keep-Session-Cookies" => "true" })
    response.get_fields("set-cookie")[0].split(";")[0]
  end

  def fetch_crumb(cookie)
    Net::HTTP.get_response(URI(CRUMB_URL), { "User-Agent" => USER_AGENT, "Cookie" => cookie }).read_body
  end

  def fetch_summary(cookie, crumb)
    uri = URI("#{API_URL}/v10/finance/quoteSummary/#{@security.symbol}?modules=assetProfile,fundProfile&crumb=#{crumb}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = USER_AGENT
    request["Cookie"] = cookie
    response = http.request(request)
    JSON.parse(response.body).dig("quoteSummary", "result", 0)
  rescue StandardError
    nil
  end

  def extract_updates(data)
    updates = {}

    if (profile = data["assetProfile"])
      updates[:sector] = profile["sector"].presence
      updates[:industry] = profile["industry"].presence
      updates[:country] = profile["country"].presence
    end

    if (fund = data["fundProfile"])
      expense = fund.dig("feesExpensesInvestment", "annualReportExpenseRatio", "raw")
      updates[:expense_ratio] = expense
    end

    updates.compact
  end
end
