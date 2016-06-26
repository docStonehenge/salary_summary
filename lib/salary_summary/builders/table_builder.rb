module SalarySummary
  module Builders
    class TableBuilder
      def initialize(container)
        @container = container
      end

      def build_entries
        @container.salaries.each do |period, amount|
          puts "#{period.to_s.capitalize}----#{amount}"
        end
      end

      def build_sum_footer
        puts "Annual Salary----#{@container.total_amount}"
      end
    end
  end
end
