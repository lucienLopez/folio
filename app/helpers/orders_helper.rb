# frozen_string_literal: true

module OrdersHelper
  def order_fees_percentage(order)
    return 0 if order.total_amount.zero?

    (order.fees / order.total_amount * 100).round(2)
  end
end
