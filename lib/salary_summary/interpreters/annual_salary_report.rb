module SalarySummary
  module Interpreters
    class AnnualSalaryReport
      def initialize(calculator)
        @calculator = calculator
      end

      def save_as_simple_document
        File.open("#{Dir.home}/annual_salary_report.csv", 'w') do |f|
          @calculator.salaries.each do |period, amount|
            f.puts "#{period}, #{amount}"
          end
          f.puts "Annual Salary, #{@calculator.total_amount}"
        end
      end
    end
  end
end
