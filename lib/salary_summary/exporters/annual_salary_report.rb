module SalarySummary
  module Exporters
    class AnnualSalaryReport
      def initialize(calculator)
        @calculator = calculator
      end

      def save(collection_name, report_file_name)
        File.open("dump/salary_summary/#{report_file_name}.csv", 'w') do |f|
          Exporters::SalariesRepository.find_on(collection_name).entries.each do |entry|
            f.puts "#{entry.dig('period').capitalize}, #{entry.dig('amount')}"
          end

          f.puts "Annual Salary, #{@calculator.sum}"
        end
      end
    end
  end
end
