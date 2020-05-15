# frozen_string_literal: true

module Checkout
  module Queries
    class StockAllocationQuery < QueryObjectBase
      def call(region: '', products: [])
        @region = region
        @products = products

        execute_query.sort_by { |stock| suppliers_index.index(stock.supplier_id) }
      end

      private

      attr_reader :region, :products

      def query
        Stock.where(product: products)
      end

      def suppliers_index
        @suppliers_index ||= suppliers_sorting_criteria_index.call(
          region: region,
          products: products
        )
      end

      def product_ids
        products.pluck(:id)
      end

      def suppliers_sorting_criteria_index
        Container['suppliers_sorting_criteria_index']
      end
    end
  end
end
