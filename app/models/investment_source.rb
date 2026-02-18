# frozen_string_literal: true

class InvestmentSource < ApplicationRecord
  has_many :investment, dependent: :nullify
end
