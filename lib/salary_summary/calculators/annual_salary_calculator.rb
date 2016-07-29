module SalarySummary
  module Calculators
    class AnnualSalaryCalculator
      def initialize(collection:)
        @collection = collection
      end

      def sum
        Exporters::SalariesRepository.sum @collection
      end
    end
  end
end
