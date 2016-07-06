module SalarySummary
  module Exporters
    class AnnualSalaryReport
      def initialize(calculator)
        @calculator = calculator
      end

      def save!(file_name)
        File.open("dump/salary_summary/#{file_name}.csv", 'w') do |f|
          @calculator.salaries.each do |period, amount|
            f.puts "#{period.capitalize}, #{amount}"
          end

          f.puts "Annual Salary, #{@calculator.total_amount}"
        end
      end
    end
  end
end
