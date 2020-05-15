# frozen_string_literal: true

class DeliveryTime < ApplicationRecord
  belongs_to :product
  belongs_to :supplier
end
