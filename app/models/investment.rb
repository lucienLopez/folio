class Investment < ApplicationRecord
  belongs_to :stock
  belongs_to :investment_source, optional: true
end
