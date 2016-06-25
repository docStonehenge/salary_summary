module SalarySummary
  module Calculators
    class AnnualSalaryCalculator
      attr_reader :salaries

      def initialize
        @salaries = {}
      end

      def enqueue(salary)
        salaries[
          salary.period.downcase.to_sym
        ] = salary.amount
      end
    end
  end
end
