# frozen_string_literal: true

module Checkout
  class StockReduceService
    include AutoInject['stock_allocation_query']

    def call(stock:, line_items:, region:)
      @stock = stock
      @line_items = line_items
      @region = region
      @shipments = Shipments.new

      reduce_stock

      shipments.to_hash
    end

    private

    attr_reader :stock, :line_items, :shipments, :region

    def reduce_stock
      line_items.map do |line_item|
        product = Product.find_by(name: line_item.name)
        quantity = line_item.quantity
        product_stock = stock.select { |stock| stock.product.id == product.id }
        reduce_product_stock(product_stock, quantity)
      end
    end

    def reduce_product_stock(product_stock, quantity)
      return unless quantity.positive?

      product_stock.each do |stock_item|
        allocated_quantity = [stock_item.in_stock, quantity].min

        quantity -= allocated_quantity

        shipments.add(
          supplier: stock_item.supplier,
          product: stock_item.product,
          count: allocated_quantity,
          delivery_date: delivery_date(stock_item)
        )
      end
    end

    def delivery_date(stock)
      Time.zone.today + stock.delivery_times(region: region).days
    end
  end
end
