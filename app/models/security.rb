# frozen_string_literal: true

class Security < ApplicationRecord
  KINDS = [
    STOCK = 'stock',
    ETF = 'etf'
  ].freeze

  belongs_to :sleeve, optional: true

  has_many :orders, dependent: :restrict_with_exception
  has_many :security_snapshots, dependent: :destroy

  validates :kind, inclusion: { in: KINDS }, allow_nil: true

  def etf? = kind == ETF
  def stock? = kind == STOCK
end
