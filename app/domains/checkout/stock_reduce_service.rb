# frozen_string_literal: true

module Checkout
  class StockReduceService
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
        reduce_product_stock(stock_for_product(product), quantity)
      end
    end

    def reduce_product_stock(product_stock, quantity)
      product_stock.each do |stock_item|
        allocated_quantity = [stock_item.in_stock, quantity].min

        quantity -= allocated_quantity

        store_shipment(stock_item, allocated_quantity)
      end
    end

    def store_shipment(stock_item, quantity)
      shipments.add(
        supplier: stock_item.supplier,
        product: stock_item.product,
        count: quantity,
        delivery_date: delivery_date(stock_item)
      )
    end

    def stock_for_product(product)
      stock.select { |stock| stock.product.id == product.id }
    end

    def delivery_date(stock)
      Time.zone.today + stock.delivery_times(region: region).days
    end
  end
end

