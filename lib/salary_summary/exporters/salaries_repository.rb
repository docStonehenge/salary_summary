module SalarySummary
  module Exporters
    class SalariesRepository
      def self.collection(name)
        Client.instance[name.to_sym]
      end

      def self.save!(salary, collection_name)
        collection(collection_name).insert_one(
          period: salary.period, amount: salary.amount
        )
      end

      def self.find_on(collection_name, options)
        collection(collection_name).find(options)
      end
    end
  end
end
