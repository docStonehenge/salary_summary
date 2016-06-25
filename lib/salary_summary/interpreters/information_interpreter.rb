module SalarySummary
  module Interpreters
    class InformationInterpreter
      def self.parse!(information)
        Resources::Salary.new(
          amount: normalize_amount(separated_entries_for(information)[1]),
          period: separated_entries_for(information)[0]
        )
      end

      def self.separated_entries_for(information)
        information.split(':')
      end

      def self.normalize_amount(entry)
        entry.sub(/^\s*\w*(\$)\s*/, '').to_f
      end

      private_class_method :separated_entries_for, :normalize_amount
    end
  end
end
