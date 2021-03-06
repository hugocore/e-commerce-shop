# frozen_string_literal: true

class CheckoutController < ApplicationController
  def allocate_basket
    command = CheckoutBasketCommand.new(
      region: checkout_params[:region],
      line_items: permitted_line_items
    )

    shipments = checkout_service.call(command)

    render json: shipments.to_json
  end

  private

  def checkout_params
    params.permit(:region, line_items: %i[name quantity])
  end

  def permitted_line_items
    checkout_params[:line_items].map do |line_item|
      {
        name: line_item[:name],
        quantity: line_item[:quantity]
      }
    end
  end

  def checkout_service
    Container['checkout_service']
  end
end
