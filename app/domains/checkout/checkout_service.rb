# frozen_string_literal: true

module Checkout
  class CheckoutService
    include AutoInject['stock_allocation_service']
    include AutoInject['stock_reduce_service']

    def call(command)
      allocated_stock = stock_allocation_service.call(
        region: command.region,
        line_items: command.line_items
      )

      stock_reduce_service.call(
        stock: allocated_stock,
        line_items: command.line_items,
        region: command.region
      )
    end
  end
end
