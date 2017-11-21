module SalarySummary
  module Persistence
    module DocumentDefinitions
      module Salary
        def self.included(klass)
          klass.class_eval do
            include(Base)
            extend(ClassMethods)

            define_field :amount, type: BigDecimal
            define_field :period, type: Date
          end
        end

        module ClassMethods
          def repository
            Repositories::SalariesRepository
          end
        end
      end
    end
  end
end
