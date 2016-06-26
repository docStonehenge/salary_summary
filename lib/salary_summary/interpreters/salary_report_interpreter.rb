module SalarySummary
  module Interpreters
    class SalaryReportInterpreter
      attr_accessor :entries, :sum

      def initialize
        @entries, @sum = {}, 0
      end

      def read_from_file(file_name)
        CSV.foreach("#{Dir.home}/salary_summary/#{file_name}.csv") do |entry|
          unless total_salary_entry?(entry)
            entries[entry[0].downcase.to_sym] = entry[1].to_f
          end

          self.sum = entry[1].to_f if total_salary_entry?(entry)
        end
      end

      private

      def total_salary_entry?(entry)
        entry[0] =~ /Annual\s?Salary/
      end
    end
  end
end
