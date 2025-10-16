module InvestmentsHelper
  def investment_fees_percentage(investment)
    return 0 if investment.total_price.zero?

    (investment.fees / investment.total_price * 100).round(2)
  end
end
