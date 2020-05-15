# frozen_string_literal: true

class Stock < ApplicationRecord
  belongs_to :product
  belongs_to :supplier

  validates :in_stock, numericality: { greater_than: 0 }
end
