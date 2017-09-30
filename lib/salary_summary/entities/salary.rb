module SalarySummary
  module Entities
    class Salary
      include Comparable

      @fields_list = []

      class << self
        attr_reader :fields_list

        private

        def fields(*names)
          names.each { |name| @fields_list << name }
          attr_accessor(*names)
        end
      end

      fields :id, :amount, :period

      def initialize(attributes)
        @id, @amount, @period = attributes.values_at(:id, :amount, :period)
      end

      def _id
        id
      end

      def year
        period.year
      end

      def month
        period.strftime('%B')
      end

      def <=>(other)
        raise ComparisonError if id.nil? or other.id.nil?
        id <=> other.id
      end
    end
  end
end
