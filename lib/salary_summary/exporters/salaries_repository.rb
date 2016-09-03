module SalarySummary
  module Exporters
    class SalariesRepository
      def self.collection
        Client.instance[:salaries]
      end

      def self.save(salary)
        collection.insert_one(period: salary.period, amount: salary.amount)
      end

      def self.find_all(options = {})
        transformed_entries_to_salaries(collection.find(options).entries)
      end

      def self.sum_by_amount
        aggregation = salaries_sum_aggregation

        aggregation.empty? ? 0 : aggregation.first.dig('sum')
      end

      def self.transformed_entries_to_salaries(entries)
        [].tap do |ary|
          entries.each do |entry|
            ary << Resources::Salary.new(
              id: entry['_id'],
              period: entry['period'].to_date,
              amount: entry['amount']
            )
          end
        end
      end

      def self.salaries_sum_aggregation
        collection.aggregate(
          [
            { :$group => { _id: 'Sum',  sum: { :$sum => '$amount' } } }
          ]
        ).entries
      end

      private_class_method :transformed_entries_to_salaries,
                           :salaries_sum_aggregation
    end
  end
end
