module SalarySummary
  module Entities
    class Salary
      include Roles::SalaryDocument

      def year
        period.year
      end

      def month
        period.strftime('%B')
      end
    end
  end
end
