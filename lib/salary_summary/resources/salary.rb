module SalarySummary
  module Resources
    class Salary
      attr_reader :id, :amount, :period

      def initialize(id: nil, amount:, period:)
        @id     = id
        @amount = amount
        @period = Date.parse(period)
      end
    end
  end
end
