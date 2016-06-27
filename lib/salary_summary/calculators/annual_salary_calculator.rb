module SalarySummary
  module Calculators
    class AnnualSalaryCalculator
      attr_reader   :salaries
      attr_accessor :total_amount

      def initialize
        @salaries, @total_amount = {}, 0
      end

      def enqueue(salary)
        salaries[
          salary.period.downcase.to_sym
        ] = salary.amount
      end

      def sum!
        self.total_amount = salaries.values.reduce(0) { |sum, amount| sum += amount }
      end
    end
  end
end
