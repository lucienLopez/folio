# frozen_string_literal: true

class PortfolioSnapshot < ApplicationRecord
  belongs_to :sleeve, optional: true

  scope :global, -> { where(sleeve_id: nil) }
  scope :for_sleeve, ->(id) { where(sleeve_id: id) }

  def perf_pct
    return 0 unless invested_eur&.positive?

    ((value_eur - invested_eur) / invested_eur * 100).round(2)
  end
end
