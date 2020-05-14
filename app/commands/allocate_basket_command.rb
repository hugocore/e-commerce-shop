# frozen_string_literal: true

class AllocateBasketCommand < CommandBase
  attribute :region, Types::Coercible::String

  attribute :line_items, Types::Array do
    attribute :name, Types::Coercible::String
    attribute :quantity, Types::Coercible::Integer.constrained(gteq: 1)
  end
end
