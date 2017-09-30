module SalarySummary
  module Resources
    class ComparisonError < StandardError
      def initialize(_message: nil)
        super("Cannot compare with an entity that isn't persisted.")
      end
    end
  end
end
