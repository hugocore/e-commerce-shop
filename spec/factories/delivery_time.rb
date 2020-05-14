# frozen_string_literal: true

FactoryBot.define do
  factory :delivery_time do
    region { 'uk' }
    days { rand(1..10) }
  end
end
