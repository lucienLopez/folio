class InvestmentsController < ApplicationController
  def index
    @investments = Investment.includes(:stock).all
  end
end
