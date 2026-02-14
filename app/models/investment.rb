class Investment < ApplicationRecord
  belongs_to :security
  belongs_to :investment_source, optional: true

  def fees
    total_price - (shares * purchase_price)
  end
end
