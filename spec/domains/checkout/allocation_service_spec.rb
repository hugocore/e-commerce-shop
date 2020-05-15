# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Checkout::AllocationService do
  subject(:allocation) { described_class.new.call(command) }

  describe '#call' do
    context 'with different suppliers (scenario 1)' do
      let(:supplier) { create :supplier }
      let(:command) do
        AllocateBasketCommand.new(
          region: region,
          line_items: [
            { name: product_a.name, quantity: 1 },
            { name: product_b.name, quantity: 1 }
          ]
        )
      end
      let(:product_a) { create :product }
      let(:product_b) { create :product }
      let(:region) { 'eu' }

      before do
        create :delivery_time, region: region, supplier: supplier, product: product_a, days: 3
        create :delivery_time, region: region, supplier: supplier, product: product_b, days: 1
        create :stock, product: product_a, supplier: supplier, in_stock: 10
        create :stock, product: product_b, supplier: supplier, in_stock: 10
      end

      it 'allocates a delivery that takes the max amount of delivery days' do
        expect(allocation[:delivery_date]).to eq((Time.zone.today + 3.days).iso8601)
      end
    end

    context 'with different products (scenario 2)' do
      let(:supplier_a) { create :supplier }
      let(:command) do
        AllocateBasketCommand.new(
          region: region,
          line_items: [
            { name: product.name, quantity: 1 }
          ]
        )
      end
      let(:supplier_b) { create :supplier }
      let(:product) { create :product }
      let(:region) { 'eu' }

      before do
        create :delivery_time, region: region, supplier: supplier_a, product: product, days: 3
        create :delivery_time, region: region, supplier: supplier_b, product: product, days: 2
        create :stock, product: product, supplier: supplier_a, in_stock: 10
        create :stock, product: product, supplier: supplier_b, in_stock: 10
      end

      it 'picks the quickest supplier to deliver the same product' do
        expect(allocation[:shipments].first[:supplier]).to eq(supplier_b.name)
      end
    end

    context 'with different products and suppliers (scenario 3)' do
      let(:command) do
        AllocateBasketCommand.new(
          region: region,
          line_items: [
            { name: t_shirt.name, quantity: 1 },
            { name: hoodie.name, quantity: 1 }
          ]
        )
      end
      let(:supplier_a) { create :supplier }
      let(:supplier_b) { create :supplier }
      let(:supplier_c) { create :supplier }
      let(:t_shirt) { create :product, name: 't-shirt' }
      let(:hoodie) { create :product, name: 'hoodie' }
      let(:region) { 'eu' }

      before do
        create :delivery_time, region: region, supplier: supplier_a, product: t_shirt, days: 1
        create :delivery_time, region: region, supplier: supplier_b, product: t_shirt, days: 1
        create :delivery_time, region: region, supplier: supplier_b, product: hoodie, days: 1
        create :delivery_time, region: region, supplier: supplier_c, product: hoodie, days: 1
        create :stock, product: t_shirt, supplier: supplier_a, in_stock: 10
        create :stock, product: t_shirt, supplier: supplier_b, in_stock: 10
        create :stock, product: hoodie, supplier: supplier_b, in_stock: 10
        create :stock, product: hoodie, supplier: supplier_c, in_stock: 10
      end

      it 'picks the quickest supplier to deliver the same product' do
        expect(allocation[:shipments].first[:supplier]).to eq(supplier_b.name)
      end
    end

    context 'with parcial shipments (scenario 4)' do
      let(:supplier_a) { create :supplier }
      let(:quantity) { 10 }
      let(:command) do
        AllocateBasketCommand.new(
          region: region,
          line_items: [
            { name: t_shirt.name, quantity: quantity }
          ]
        )
      end
      let(:supplier_b) { create :supplier }
      let(:supplier_a_stock) { 6 }
      let(:supplier_b_stock) { 7 }
      let(:t_shirt) { create :product, name: 't-shirt' }
      let(:region) { 'eu' }

      before do
        create :delivery_time, region: region, supplier: supplier_a, product: t_shirt, days: 1
        create :delivery_time, region: region, supplier: supplier_b, product: t_shirt, days: 1
        create :stock, product: t_shirt, supplier: supplier_a, in_stock: supplier_a_stock
        create :stock, product: t_shirt, supplier: supplier_b, in_stock: supplier_b_stock
      end

      it 'allocates shipments from different suppliers to fullfil the basket' do
        expect(allocation[:shipments].size).to eq(2)
      end

      it 'picks a parcial amount from one supplier' do
        shipment = allocation[:shipments].find { |s| s[:supplier] == supplier_a.name }

        expect(shipment[:items].first).to eq({ title: t_shirt.name, count: supplier_a_stock })
      end

      it 'picks a parcial amount from another supplier' do
        shipment = allocation[:shipments].find { |s| s[:supplier] == supplier_b.name }
        count = quantity - supplier_a_stock

        expect(shipment[:items].first).to eq({ title: t_shirt.name, count: count })
      end
    end
  end
end
