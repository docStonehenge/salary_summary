module SalarySummary
  module Builders
    class TableBuilder
      def initialize(repository)
        @repository = repository
      end

      def build_entries_on(collection_name)
        @repository.find_on(collection_name).each do |salary|
          puts "#{salary.period}----#{salary.amount}"
        end
      end

      def build_sum_footer_for(collection_name)
        puts "Annual Salary----#{@repository.sum(collection_name)}"
      end
    end
  end
end
