# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @orders = Order.includes(:security).all
  end
end
