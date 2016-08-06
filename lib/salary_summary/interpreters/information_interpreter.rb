module SalarySummary
  module Interpreters
    class InformationInterpreter
      def parse(information)
        Resources::Salary.new(
          amount: normalize_amount(separated_entries_for(information)[1]),
          period: "#{formatted_period_on(information)[:month]}, #{formatted_period_on(information)[:year]}"
        )
      end

      private

      def separated_entries_for(information)
        information.split(':')
      end

      def normalize_amount(entry)
        entry.sub(/^\s*\w*(\$)\s*/, '').to_f
      end

      def formatted_period_on(information)
        period = separated_entries_for(information)[0].split('/')
        Hash[month: period[0], year: period[1]]
      end
    end
  end
end
