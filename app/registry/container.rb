# frozen_string_literal: true

class Container
  extend Dry::Container::Mixin

  register(:allocation_service) { Checkout::AllocationService.new }
end
