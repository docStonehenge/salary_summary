module SalarySummary
  module Interpreters
    class AnnualSalaryReport
      def initialize(calculator)
        @calculator = calculator
      end

      def save_as_simple_document(file_name)
        normalize_path_for_report_file!

        File.open("#{Dir.home}/salary_summary/#{file_name}.csv", 'w') do |f|
          @calculator.salaries.each do |period, amount|
            f.puts "#{period.capitalize}, #{amount}"
          end

          f.puts "Annual Salary, #{@calculator.total_amount}"
        end
      end

      private

      def normalize_path_for_report_file!
        unless Dir.exist?("#{Dir.home}/salary_summary")
          FileUtils.mkdir("#{Dir.home}/salary_summary")
        end
      end
    end
  end
end
