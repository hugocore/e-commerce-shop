# frozen_string_literal: true

module Checkout
  module Queries
    class IndexSuppliersByShipments < QueryObjectBase
      def call(region: '', products: [])
        @region = region
        @products = products

        execute_raw_query.map { |group| group['stocks_supplier_id'] }
      end

      private

      attr_reader :region, :products

      def query
        scoped = select_stock_by_supplier_delivery_days
        scoped = filter_by_products(scoped)
        scoped = filter_by_region(scoped)
        scoped = group_by_suppliers_and_delivery_days(scoped)
        scoped = sort_by_less_suppliers_and_delivery_days(scoped)

        scoped.to_sql
      end

      def select_stock_by_supplier_delivery_days
        Stock.select(
          <<~SQL
            COUNT(*) AS count_all,
            stocks.supplier_id AS stocks_supplier_id,
            delivery_times.days AS delivery_days
          SQL
        )
      end

      def filter_by_products(scoped)
        products.present? ? scoped.where(product_id: products.pluck(:id)) : scoped
      end

      def filter_by_region(scoped)
        region ? scoped.where(delivery_times: { region: region }) : scoped
      end

      def sort_by_less_suppliers_and_delivery_days(scoped)
        scoped.order(count_all: :desc, delivery_days: :asc)
      end

      def group_by_suppliers_and_delivery_days(scoped)
        scoped.joins(:delivery_times).group(:supplier_id, :days)
      end
    end
  end
end
