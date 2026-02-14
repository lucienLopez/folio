class InvestmentsController < ApplicationController
  def index
    @investments = Investment.includes(:security).all
  end
end
