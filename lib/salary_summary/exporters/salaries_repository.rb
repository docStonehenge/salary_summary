module SalarySummary
  module Exporters
    class SalariesRepository
      def self.collection(name)
        Client.instance[name.to_sym]
      end
    end
  end
end
