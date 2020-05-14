# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Stock, type: :model do
  subject(:stock) { create :stock, product: product, supplier: supplier }

  let(:product) { create :product }
  let(:supplier) { create :supplier }

  it { is_expected.to have_attributes(product: product) }
  it { is_expected.to have_attributes(supplier: supplier) }
  it { is_expected.to have_attributes(in_stock: (a_value > 0)) }

  context 'with an invalid stock amount' do
    subject(:stock) { create :stock, in_stock: in_stock }

    let(:in_stock) { -1 }

    it 'raises a validation error' do
      expect { stock }.to raise_error ActiveRecord::RecordInvalid
    end
  end
end
