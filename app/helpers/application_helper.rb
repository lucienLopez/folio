# frozen_string_literal: true

module ApplicationHelper
  # Renders a day-change badge: "+1 234 € (+1.23%)" styled green/red.
  # stats: { change: Float, pct: Float } or nil
  def day_change_badge(stats, size: :normal)
    return unless stats

    change = stats[:change]
    pct    = stats[:pct]
    positive = change >= 0
    sign   = positive ? "+" : "−"
    color  = positive ? "text-emerald-600" : "text-red-500"
    text_size = size == :small ? "text-xs" : "text-sm"

    amount_str = number_to_currency(change.abs, unit: "€", precision: 2, delimiter: "\u202F", separator: ".")
    pct_str    = pct ? " (#{sign}#{number_with_precision(pct.abs, precision: 2)}%)" : ""

    content_tag(:span, "#{sign}#{amount_str}#{pct_str}", class: "#{text_size} font-medium #{color}")
  end
end
