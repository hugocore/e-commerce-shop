# frozen_string_literal: true

class CreateStocks < ActiveRecord::Migration[6.0]
  def change
    create_table :stocks do |t|
      t.references :product, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.integer :in_stock

      t.timestamps
    end
  end
end
