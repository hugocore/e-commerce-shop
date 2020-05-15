# frozen_string_literal: true

class Stock < ApplicationRecord
  belongs_to :product
  belongs_to :supplier

  validates :in_stock, numericality: { greater_than: 0 }

  def delivery_times(region:)
    DeliveryTime.find_by(product: product, supplier: supplier, region: region)
  end
end
