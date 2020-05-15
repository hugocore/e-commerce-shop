# frozen_string_literal: true

class Supplier < ApplicationRecord
  has_many :delivery_times, dependent: :destroy
  has_many :stock, dependent: :destroy
end
