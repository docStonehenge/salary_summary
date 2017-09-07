module SalarySummary
  module Resources
    class Salary
      include Comparable

      attr_reader :id, :amount, :period, :comparable_key

      def initialize(id: nil, amount:, period:)
        @id             = id
        @amount         = amount
        @period         = period
        @comparable_key = :id
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

      def comparable_key=(key)
        @comparable_key = key.to_sym if respond_to?(key.to_s)
      end

      def <=>(other)
        public_send(@comparable_key) <=> other.public_send(@comparable_key)
      end
    end
  end
end
