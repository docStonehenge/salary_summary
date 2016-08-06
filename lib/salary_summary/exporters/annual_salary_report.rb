module SalarySummary
  module Exporters
    class AnnualSalaryReport
      def initialize(repository)
        @repository = repository
      end

      def export(report_file_name)
        File.open("dump/salary_summary/#{report_file_name}.csv", 'w') do |f|
          @repository.find.each do |salary|
            f.puts "#{salary.month.capitalize}/#{salary.year}, #{salary.amount}"
          end

          f.puts "Total, #{@repository.sum}"
        end
      end
    end
  end
end
