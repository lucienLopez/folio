class Stock < ApplicationRecord
  has_many :investments, dependent: :restrict_with_exception
  has_many :stock_snapshots, dependent: :destroy
end
