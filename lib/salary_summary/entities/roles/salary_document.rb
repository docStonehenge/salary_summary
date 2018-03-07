module SalarySummary
  module Entities
    module Roles
      module SalaryDocument
        def self.included(klass)
          klass.class_eval do
            include(Persisty::Persistence::DocumentDefinitions::Base)
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
