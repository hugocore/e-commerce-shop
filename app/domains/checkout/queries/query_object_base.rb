# frozen_string_literal: true

module Checkout
  module Queries
    class QueryObjectBase
      def execute_query
        send(:query)
      end

      def execute_raw_query
        ActiveRecord::Base.connection.execute(send(:query))&.to_a
      end
    end
  end
end
