# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckoutController, type: :controller do
  describe 'POST allocate_basket' do
    let(:region) { 'eu' }
    let(:product) { create :product }
    let(:supplier) { create :supplier }
    let(:line_items) do
      [
        {
          name: product.name,
          quantity: 5
        }
      ]
    end

    before do
      create :delivery_time, region: region, supplier: supplier, product: product, days: 1
      create :stock, product: product, supplier: supplier, in_stock: 10

      post :allocate_basket, params: { region: region, line_items: line_items }
    end

    it 'responds with a 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns shipements that matches the schema' do
      expect(response).to match_response_schema('shipments')
    end
  end
end
