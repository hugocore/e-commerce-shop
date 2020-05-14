# frozen_string_literal: true

FactoryBot.define do
  factory :supplier do
    name { Faker::Name.name }
  end
end
