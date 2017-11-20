module SalarySummary
  module Entities
    module Roles
      module BaseDocument
        include Comparable

        def self.included(base)
          base.class_eval do
            extend(ClassMethods)

            @fields_list = [] # Collection of attributes set on entity, as symbols.
            @fields      = {} # Contains specifications of field names and types.

            define_field :id, type: BSON::ObjectId
            alias_method :_id, :id
            alias_method :_id=, :id=

            class << self
              attr_reader :fields_list, :fields
            end
          end
        end

        # Initializes instance using +fields+ specifications to set values.
        # Initialization can receive any set of attributes, with Symbol or String keys.
        # Field coercion is made on every attribute, given specifications on each field,
        # set by .field method.
        #
        # Examples
        #
        # Entity.new
        # #=> #<Entity:0x007fe9232bd0e0 @id=nil, @first_name=nil>
        #
        # Entity.new(first_name: "John Doe")
        # #=> #<Entity:0x007fe9232bd0e0 @id=nil, @first_name="John Doe">
        #
        #
        # Can initialize with 'id' attribute as 'id' or '_id':
        #
        # Entity.new(id: BSON::ObjectId.new)
        # #=> #<Entity:0x007fe9232bd0e0 @id=BSON::ObjectId('5a1246d46582e8676af472c7'), @first_name=nil>
        #
        # Entity.new(_id: BSON::ObjectId.new)
        # #=> #<Entity:0x007fe9232bd0e0 @id=BSON::ObjectId('5a1246d46582e8676af472c7'), @first_name=nil>
        #
        #
        # Any argument that isn't resolved as a field on entity, will be ignored.
        #
        # Entity.new(foo: 1234)
        # #=> #<Entity:0x007fe9232bd0e0 @id=nil, @first_name=nil>
        def initialize(attributes = {})
          attributes = attributes.each_with_object({}) do |(name, value), attrs|
            attrs[name.to_sym] = value
          end

          attributes[:id] = attributes[:_id] || attributes[:id]

          self.class.fields.each do |name, spec|
            instance_variable_set(
              :"@#{name}",
              Persistence::Entities::Field.new(
                type: spec.dig(:type), value: attributes.dig(name)
              ).coerce
            )
          end
        end

        def <=>(other)
          raise ComparisonError if id.nil? or other.id.nil?
          id <=> other.id
        end

        module ClassMethods
          def repository
            raise NotImplementedError
          end

          # Defines accessors methods for field <tt>name</tt>, considering <tt>type</tt> to use
          # coercion when setting value. Also, fills +fields_list+ with <tt>name</tt>
          # and +fields+ hash with <tt>name</tt> and <tt>type</tt>.
          # For any attributes besides 'id', calls registration of entity object
          # into current UnitOfWork.
          #
          # Examples
          #
          #   class Entity
          #     define_field :first_name, type: String
          #   end
          #
          #   Entity.fields_list
          #   #=> [:first_name]
          #
          #   Entity.fields
          #   #=> {:first_name=>{:type=>String}
          #
          #   Entity.new.first_name = "John Doe"
          #   Entity.new.first_name
          #   #=> "John Doe"
          def define_field(name, type:)
            name = name.to_sym

            @fields_list.push(name)
            @fields[name] = { type: type }

            attr_reader name
            define_setter_method_for name, type
          end

          private

          def define_setter_method_for(attribute, type) # :nodoc:
            instance_eval do
              define_method("#{attribute}=") do |value|
                instance_variable_set(
                  :"@#{attribute}",
                  Persistence::Entities::Field.new(type: type, value: value).coerce
                )

                unless attribute == :id
                  begin
                    Persistence::UnitOfWork.current.register_changed(self)
                  rescue Persistence::UnitOfWorkNotStartedError
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
