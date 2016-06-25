module SalarySummary
  module Resources
    class Salary
      attr_reader :amount, :period

      def initialize(amount:, period:)
        @amount, @period = amount, period
      end
    end
  end
end
