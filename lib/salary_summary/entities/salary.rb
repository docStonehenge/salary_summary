module SalarySummary
  module Entities
    class Salary
      include Comparable

      @fields_list = []

      class << self
        # Collection of attributes set on entity, as symbols.
        attr_reader :fields_list

        # Returns the repository class used to persist objects of this class
        # into the database.
        def repository
          Repositories::SalariesRepository
        end

        private

        def fields(*names) # :nodoc:
          names.each do |name|
            @fields_list << name.to_sym

            if name == :id
              attr_accessor(:id)
            else
              attr_reader name
              define_setter_method_for name
            end
          end
        end

        def define_setter_method_for(attribute) # :nodoc:
          instance_eval do
            define_method("#{attribute}=") do |value|
              instance_variable_set(:"@#{attribute}", value)

              begin
                Persistence::UnitOfWork.current.register_changed(self)
              rescue Persistence::UnitOfWorkNotStartedError
              end
            end
          end
        end
      end

      # Defines accessors for entity attributes. For other attributes besides <tt>id</tt>,
      # the setter method created will try to register entity on current UnitOfWork,
      # if there's any available on Thread.
      fields :id, :amount, :period

      # Initializes instance using +fields_list+ class attribute to set values.
      def initialize(attributes)
        self.class.fields_list.each do |field|
          instance_variable_set(:"@#{field}", attributes.dig(field))
        end
      end

      def _id
        id
      end

      def year
        period.year
      end

      def month
        period.strftime('%B')
      end

      def <=>(other)
        raise ComparisonError if id.nil? or other.id.nil?
        id <=> other.id
      end
    end
  end
end
