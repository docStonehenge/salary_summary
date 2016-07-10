module SalarySummary
  module Exporters
    class SalariesRepository
      def self.collection(name)
        Client.instance[name.to_sym]
      end

      def self.save(salary, collection_name)
        collection(collection_name).insert_one(
          period: salary.period, amount: salary.amount
        )
      end

      def self.find_on(collection_name, as_object = false, options = {})
        salaries = collection(collection_name).find(options).entries
        return salaries unless as_object
        transformed_entries_to_salaries(salaries)
      end

      def self.sum(collection_name)
        collection(collection_name).aggregate(
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
              period: entry['period'],
              amount: entry['amount']
            )
          end
        end
      end

      private_class_method :transformed_entries_to_salaries
    end
  end
end
