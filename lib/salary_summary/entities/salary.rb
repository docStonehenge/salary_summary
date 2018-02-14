module SalarySummary
  module Entities
    class Salary
      include Persistence::DocumentDefinitions::Salary

      def year
        period.year
      end

      def month
        period.strftime('%B')
      end
    end
  end
end
