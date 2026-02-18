# frozen_string_literal: true

class SecuritiesController < ApplicationController
  def index
    @securities = Security.left_joins(:investments)
                          .group(:id)
                          .select("securities.*, COUNT(investments.id) AS investments_count")
  end

  def edit
    @security = Security.find(params[:id])
  end

  def update
    @security = Security.find(params[:id])

    if @security.update(security_params)
      redirect_to securities_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def security_params
    params.require(:security).permit(:name, :symbol, :kind, :isin)
  end
end
