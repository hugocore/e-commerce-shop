# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :delivery_times
  has_many :stock
end
