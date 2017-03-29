module SalarySummary
  module Builders
    class TableBuilder
      include TablePrint

      def initialize(repository)
        @repository = repository
      end

      def build_entries
        tp(
          @repository.find_all(sorted_by: { period: 1 }),
          :month, :year, :amount
        )
      end

      def build_sum_footer
        puts "Total ---- #{@repository.sum_by_amount}"
      end
    end
  end
end
