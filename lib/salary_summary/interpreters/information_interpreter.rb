module SalarySummary
  module Interpreters
    class InformationInterpreter
      def parse(information)
        Resources::Salary.new(
          amount: normalize_amount(separated_entries_for(information)[1]),
          period: Date.parse(separated_entries_for(information)[0])
        )
      rescue ArgumentError
      end

      private

      def separated_entries_for(information)
        information.split(':')
      end

      def normalize_amount(entry)
        entry.sub(/^\s*\w*(\$)\s*/, '').to_f
      end
    end
  end
end
