module SalarySummary
  module Interpreters
    class SalaryReportInterpreter
      attr_accessor :salaries, :total_amount

      def initialize
        @salaries, @total_amount = {}, 0
      end

      def read_from_file(file_name)
        CSV.foreach("#{Dir.home}/salary_summary/#{file_name}.csv") do |entry|
          unless total_salary_entry?(entry)
            salaries[entry[0].downcase.to_sym] = entry[1].to_f
          end

          self.total_amount = entry[1].to_f if total_salary_entry?(entry)
        end
      end

      private

      def total_salary_entry?(entry)
        entry[0] =~ /Annual\s?Salary/
      end
    end
  end
end
