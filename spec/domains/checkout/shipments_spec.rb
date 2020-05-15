# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Checkout::Shipments do
  subject(:checkout_shipments) { described_class.new }

  describe '#add' do
    let(:supplier) { create :supplier }
    let(:product) { create :product }
    let(:count) { 1 }
    let(:delivery_date) { Time.zone.today + 1.day }

    it 'stores a new shipment' do
      expect do
        checkout_shipments.add(
          supplier: supplier, product: product, count: count, delivery_date: delivery_date
        )
      end.to change(checkout_shipments.shipments, :count)
    end
  end

  describe '#to_hash' do
    context 'with multiple shipments' do
      let(:count) { 1 }
      let(:delivery_date_tomorrow) { Time.zone.today + 1.day }
      let(:delivery_date_late) { Time.zone.today + 2.days }
      let(:supplier_a) { create :supplier }
      let(:supplier_b) { create :supplier }
      let(:product_a) { create :product }
      let(:product_b) { create :product }

      before do
        checkout_shipments.add(
          supplier: supplier_a,
          product: product_a,
          count: count,
          delivery_date: delivery_date_tomorrow
        )

        checkout_shipments.add(
          supplier: supplier_b,
          product: product_b,
          count: count,
          delivery_date: delivery_date_late
        )
      end

      it 'returns the latest delivery date at the root' do
        expect(checkout_shipments.to_hash[:delivery_date]).to eq(delivery_date_late)
      end

      it 'groups shipments by supplier' do
        shipments = checkout_shipments.to_hash[:shipments]
        suppliers = shipments.map { |shipment| shipment[:supplier] }

        expect(suppliers).to eq([supplier_a.name, supplier_b.name])
      end

      it 'sets shipments with the latest delivery date per supplier' do
        shipments = checkout_shipments.to_hash[:shipments]
        delivery_dates = shipments.map { |shipment| shipment[:delivery_date] }

        expect(delivery_dates).to eq([delivery_date_tomorrow, delivery_date_late])
      end

      it 'lists products by supplier' do
        shipments = checkout_shipments.to_hash[:shipments]
        items = shipments.flat_map { |shipment| shipment[:items] }
        titles = items.flat_map { |shipment| shipment[:title] }

        expect(titles).to eq([product_a.name, product_b.name])
      end
    end
  end
end
