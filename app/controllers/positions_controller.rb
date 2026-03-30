# frozen_string_literal: true

class PositionsController < ApplicationController
  def index
    @positions = PositionsBuilder.call
  end
end
