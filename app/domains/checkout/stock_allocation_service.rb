# frozen_string_literal: true

module Checkout
  class StockAllocationService
    include AutoInject['stock_allocation_query']

    def call(region:, line_items:)
      @region = region
      @line_items = line_items

      return [] if products.blank?

      allocated_stock
    end

    private

    attr_reader :region, :line_items

    def products
      Product.where(name: line_items.map(&:name))&.uniq
    end

    def allocated_stock
      stock_allocation_query.call(
        region: region,
        products: products
      )
    end
  end
end
