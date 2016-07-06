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
    end
  end
end
