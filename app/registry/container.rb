# frozen_string_literal: true

class Container
  extend Dry::Container::Mixin

  register(:allocation_service) { Checkout::AllocationService.new }
  register(:stock_allocation_query) { Checkout::Queries::StockAllocationQuery.new }
  register(:suppliers_sorting_criteria_index) { Checkout::Queries::IndexSuppliersByShipments.new }
end
