# frozen_string_literal: true

class Security < ApplicationRecord
  KINDS = [
    STOCK = 'stock',
    ETF = 'etf'
  ].freeze

  has_many :investments, dependent: :restrict_with_exception
  has_many :security_snapshots, dependent: :destroy

  validates :kind, inclusion: { in: KINDS }, allow_nil: true
end
