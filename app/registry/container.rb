# frozen_string_literal: true

class Container
  extend Dry::Container::Mixin

  # Domains
  register(:checkout_service) { Checkout::CheckoutService.new }
  register(:stock_allocation_service) { Checkout::StockAllocationService.new }
  register(:stock_reduce_service) { Checkout::StockReduceService.new }

  # Queries
  register(:stock_allocation_query) { Checkout::Queries::StockAllocationQuery.new }
  register(:suppliers_sorting_criteria_index) { Checkout::Queries::IndexSuppliersByShipments.new }
end
