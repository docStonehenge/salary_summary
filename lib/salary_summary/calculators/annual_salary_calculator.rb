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
        salaries.each do |_, amount|
          self.total_amount += amount
        end
      end
    end
  end
end
