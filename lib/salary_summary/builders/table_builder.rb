module SalarySummary
  module Builders
    class TableBuilder
      def initialize(repository)
        @repository = repository
      end

      def build_entries
        @repository.find_all(sorted_by: { period: 1 }).each do |salary|
          puts "#{salary.month}, #{salary.year} ---- #{salary.amount}"
        end
      end

      def build_sum_footer
        puts "Total ---- #{@repository.sum_by_amount}"
      end
    end
  end
end
