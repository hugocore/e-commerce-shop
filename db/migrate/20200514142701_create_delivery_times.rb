# frozen_string_literal: true

class CreateDeliveryTimes < ActiveRecord::Migration[6.0]
  def change
    create_table :delivery_times do |t|
      t.string :region
      t.integer :days
      t.references :product, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
    add_index :delivery_times, :region
    add_index :delivery_times, %i[region supplier_id product_id], unique: true
  end
end
