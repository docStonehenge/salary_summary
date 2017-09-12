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
        get_entries(modifier, sorted_by).map do |entry|
          if (registered_salary = Registry.get(entry.dig('_id')))
            registered_salary
          else
            Registry.set(instantiate_salary_with(entry))
          end
        end
      end

      def sum_by_amount
        aggregation = salaries_sum_aggregation
        aggregation.empty? ? 0 : aggregation.first.dig('sum')
      end

      private

      def get_entries(modifier, sorted_by)
        query = @collection.find(modifier)
        query = query.sort(sorted_by) unless sorted_by.empty?

        query.entries
      end

      def instantiate_salary_with(entry)
        @object_klass.new(
          id: entry['_id'],
          period: entry['period'].to_date,
          amount: entry['amount']
        )
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
