module SalarySummary
  module Builders
    class TableBuilder
      def initialize(using_repository:)
        @repository = using_repository
      end

      def build_entries_on(collection_name)
        @repository.find_on(collection_name).each do |entry|
          puts "#{entry.dig('period')}----#{entry.dig('amount')}"
        end
      end

      # def build_sum_footer
      #   puts "Annual Salary----#{@container.total_amount}"
      # end
    end
  end
end
