module SalarySummary
  module Entities
    module Roles
      module SalaryDocument
        def self.included(base)
          base.class_eval do
            include(BaseDocument)
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
