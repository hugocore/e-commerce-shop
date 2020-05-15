module Checkout
  class Shipments
    attr_reader :shipments

    def initialize
      @shipments = []
    end

    def add(supplier:, product:, count:, delivery_date:)
      @shipments << OpenStruct.new(
        supplier: supplier,
        product: product,
        count: count,
        delivery_date: delivery_date
      )
    end

    def to_hash
      {
        delivery_date: delivery_date(shipments),
        shipments: shipments_by_supplier.map do |supplier, supplier_shipments|
          {
            supplier: supplier.name,
            delivery_date: delivery_date(supplier_shipments),
            items: supplier_shipments.map do |line_item|
              {
                title: line_item.product.name,
                count: line_item.count
              }
            end
          }
        end
      }
    end

    private

    def delivery_date(shipments_subset)
      shipments_subset.map(&:delivery_date).max
    end

    def shipments_by_supplier
      shipments.group_by(&:supplier)
    end
  end
end
