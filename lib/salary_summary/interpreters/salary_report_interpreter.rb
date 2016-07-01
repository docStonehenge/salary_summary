module SalarySummary
  module Interpreters
    class SalaryReportInterpreter
      def initialize(calculator)
        @calculator = calculator
      end

      def read_from_file(file_name)
        CSV.foreach("dump/salary_summary/#{file_name}.csv") do |entry|
          unless total_salary_entry?(entry)
            @calculator.enqueue(
              Resources::Salary.new(amount: entry[1].to_f, period: entry[0])
            )
          end
        end

        @calculator.sum!
      end

      private

      def total_salary_entry?(entry)
        entry[0] =~ /Annual\s?Salary/
      end
    end
  end
end
