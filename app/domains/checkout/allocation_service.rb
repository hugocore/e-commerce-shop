# frozen_string_literal: true

module Checkout
  class AllocationService
    include AutoInject['stock_allocation_query']

    def call(command)
      @command = command

      return if products_in_basket.blank?

      shipments = Shipments.new

      command.line_items.map do |line_item|
        product = Product.find_by(name: line_item.name)
        quantity = line_item.quantity

        # group by product
        stock_items = allocated_stock.select { |stock| stock.product.id == product.id }

        # reduce
        stock_items.each do |stock_item|
          break unless quantity.positive?

          allocated_quantity = [stock_item.in_stock, quantity].min

          quantity -= allocated_quantity

          shipments.add(
            supplier: stock_item.supplier,
            product: stock_item.product,
            count: allocated_quantity,
            delivery_date: Time.zone.today + stock_item.delivery_times(region: command.region).days
          )
        end
      end

      shipments.to_hash
    end

    private

    attr_reader :command

    def products_in_basket
      Product.where(name: command.line_items.map(&:name))&.uniq
    end

    def products_in_stock
      Stock.where(product: products_in_basket)
    end

    def allocated_stock
      @stock ||= stock_allocation_query.call(
        region: command.region,
        products: products_in_basket
      )
    end
  end
end
