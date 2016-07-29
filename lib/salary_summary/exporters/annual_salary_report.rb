module SalarySummary
  module Exporters
    class AnnualSalaryReport
      def initialize(repository)
        @repository = repository
      end

      def save(collection_name, report_file_name)
        File.open("dump/salary_summary/#{report_file_name}.csv", 'w') do |f|
          @repository.find_on(collection_name).each do |salary|
            f.puts "#{salary.period.capitalize}, #{salary.amount}"
          end

          f.puts "Annual Salary, #{@repository.sum(collection_name)}"
        end
      end
    end
  end
end
