# frozen_string_literal: true

class CreateSuppliers < ActiveRecord::Migration[6.0]
  def change
    create_table :suppliers do |t|
      t.string :name, unique: true

      t.timestamps
    end
    add_index :suppliers, :name
  end
end
