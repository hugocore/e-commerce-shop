# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckoutController, type: :controller do
  describe 'POST create' do
    let(:region) { 'eu' }
    let(:product) { create :product }
    let(:supplier) { create :supplier }
    let(:line_items) do
      [
        {
          name: product.name,
          count: 5
        }
      ]
    end

    before do
      create :delivery_time, region: region, supplier: supplier, product: product, days: 1
      create :stock, product: product, supplier: supplier, in_stock: 10

      post :create, params: { region: region, line_items: line_items }
    end

    it 'responds with a 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'calculates a delivery with a date' do
      expect(JSON.parse(response)[:delivery_date]).to eq(Date.tomorrow)
    end

    it 'allocates shipments per product' do
      expect(JSON.parse(response)[:shipments].count).to eq(1)
    end
  end
end
