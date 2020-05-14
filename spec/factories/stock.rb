# frozen_string_literal: true

FactoryBot.define do
  factory :stock do
    product
    supplier
    in_stock { rand(1..10) }
  end
end
