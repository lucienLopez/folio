class Stock < ApplicationRecord
  has_many :investments, dependent: :restrict_with_exception
end
