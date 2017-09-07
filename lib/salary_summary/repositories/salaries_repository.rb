module SalarySummary
  module Repositories
    class SalariesRepository
      def initialize(connection_client = Client.instance)
        @collection   = connection_client[:salaries]
        @object_klass = Resources::Salary
      end

      def save(salary)
        @collection.insert_one(period: salary.period, amount: salary.amount)
      end

      def find_all(modifier: {}, sorted_by: {})
        result = @collection.find(modifier)
        result = result.sort(sorted_by) unless sorted_by.empty?

        transformed_entries_to_salaries(result.entries)
      end

      def sum_by_amount
        aggregation = salaries_sum_aggregation

        aggregation.empty? ? 0 : aggregation.first.dig('sum')
      end

      private

      def transformed_entries_to_salaries(entries)
        [].tap do |ary|
          entries.each do |entry|
            ary << @object_klass.new(
              id: entry['_id'],
              period: entry['period'].to_date,
              amount: entry['amount']
            )
          end
        end
      end

      def salaries_sum_aggregation
        @collection.aggregate(
          [
            { :$group => { _id: 'Sum', sum: { :$sum => '$amount' } } }
          ]
        ).entries
      end
    end
  end
end
