module SalarySummary
  module Resources
    class Salary
      class PeriodError < StandardError; end

      attr_reader :id, :amount, :period

      def initialize(id: nil, amount:, period:)
        @id     = id
        @amount = amount
        @period = Date.parse(period)
      rescue ArgumentError
        raise PeriodError, 'Unknown date to set a period.'
      end

      def year
        period.year
      end

      def month
        period.strftime('%B')
      end
    end
  end
end
