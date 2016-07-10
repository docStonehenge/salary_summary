module SalarySummary
  module Builders
    class TableBuilder
      def self.build_entries_on(collection_name)
        Exporters::SalariesRepository.find_on(collection_name).each do |entry|
          puts "#{entry.dig('period')}----#{entry.dig('amount')}"
        end
      end

      def self.build_sum_footer_with(calculator)
        puts "Annual Salary----#{calculator.sum}"
      end
    end
  end
end
