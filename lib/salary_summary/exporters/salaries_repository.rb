module SalarySummary
  module Exporters
    class SalariesRepository
      def self.collection
        Client.instance[:salaries]
      end

      def self.save(salary)
        collection.insert_one(
          month: salary.month, year: salary.year, amount: salary.amount
        )
      end

      def self.find(options = {})
        transformed_entries_to_salaries(collection.find(options).entries)
      end

      def self.sum
        collection.aggregate(
          [
            { :$group => { _id: 'Sum',  sum: { :$sum => '$amount' } } }
          ]
        ).entries.first.dig('sum')
      end

      def self.transformed_entries_to_salaries(entries)
        [].tap do |ary|
          entries.each do |entry|
            ary << Resources::Salary.new(
              id: entry['_id'],
              period: "#{entry['month']}, #{entry['year']}",
              amount: entry['amount']
            )
          end
        end
      end

      private_class_method :transformed_entries_to_salaries
    end
  end
end
