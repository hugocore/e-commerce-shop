# frozen_string_literal: true

module Checkout
  class AllocationService
    def call(command)
      @command = command

      return unless products_in_basket.present?

      shipments = []

      command.line_items.map do |line_item|
        product = Product.find_by(name: line_item.name)
        quantity = line_item.quantity

        # group by product
        stock_items = in_stock.group_by(&:product_id)[product.id]

        # reduce
        stock_items.each do |stock_item|
          break unless quantity.positive?

          allocated_quantity = [stock_item.in_stock, quantity].min

          quantity = quantity - allocated_quantity

          shipments << {
            stock: stock_item,
            supplier: stock_item.supplier,
            productd: stock_item.product,
            count: allocated_quantity
          }
        end
      end

      shipments
    end

    private

    attr_reader :command

    def products_in_basket
      Product.where(name: command.line_items.map(&:name))&.uniq
    end

    def products_in_stock
      Stock.where(product: products_in_basket)
    end

    def in_stock
      query = <<-SQL
        SELECT
          COUNT(*) AS count_all,
          stocks.supplier_id AS stocks_supplier_id,
          delivery_times.days
        FROM stocks
          LEFT OUTER JOIN delivery_times
            ON delivery_times.product_id = stocks.product_id
            AND delivery_times.supplier_id = stocks.supplier_id
            AND delivery_times.region = 'eu'
        WHERE stocks.product_id IN (#{products_in_basket.map(&:id).join(',')})
        GROUP BY stocks.supplier_id, delivery_times.days
        ORDER BY count_all DESC, delivery_times.days ASC
      SQL

      array = ActiveRecord::Base.connection.execute(query).to_a.map { |a| a['stocks_supplier_id'] }

      products_in_stock.sort_by { |stock| array.index(stock.supplier_id) }
    end
  end
end
