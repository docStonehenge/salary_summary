module SalarySummary
  module Databases
    module MongoDB
      class AggregationWrapper
        attr_reader :stages

        instance_eval do
          [:project, :match, :redact, :limit, :skip, :sort].each do |stage|
            define_method(stage) do |specifications|
              push_stage_as stage, specifications
            end
          end
        end

        def initialize
          @stages = []
        end

        def unwind(field_name)
          push_stage_as :unwind, "$#{field_name}"
        end

        def group(expression_id, grouping_expression)
          push_stage_as(
            :group,
            { _id: expression_id }.merge(grouping_expression)
          )
        end

        def sample(sample_size)
          push_stage_as :sample, size: sample_size
        end

        private

        def push_stage_as(stage_name, specifications)
          @stages << { :"$#{stage_name}" => specifications }
        end
      end
    end
  end
end
