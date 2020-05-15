# frozen_string_literal: true

class Supplier < ApplicationRecord
  has_many :delivery_times
  has_many :stock
end
