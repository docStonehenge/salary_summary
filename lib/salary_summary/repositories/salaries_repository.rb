module SalarySummary
  module Repositories
    class SalariesRepository
      include Persisty::Repositories::Base

      def sum_by_amount
        aggregation = sum_aggregation
        aggregation.empty? ? 0 : aggregation.first.dig('sum')
      end

      private

      def entity_klass
        Entities::Salary
      end

      def collection_name
        :salaries
      end

      def sum_aggregation
        aggregate { group nil, { sum: { :$sum => '$amount' } } }
      end
    end
  end
end
