module Queries
  module AlternateValue
    class Filter

      include Queries::Helpers

      # General annotator options handling
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      # @params options [ ActionController::Parameters instance ]
      attr_accessor :options

      # Params specific to AlternateValue
      attr_accessor :value, :language_id, :type, :alternate_value_object_attribute

      # Note that this is always(?) passed in on controller calls
      attr_accessor :project_id

      # @params params [ActionController::Parameters]
      def initialize(params)
        @value = params[:value]
        @language_id = params[:language_id]
        @type = params[:type]
        @alternate_value_object_attribute = params[:alternate_value_object_attribute]
        @options = params
        @project_id = params[:project_id]
      end

      def annotated_class
        ::Queries::Annotator.annotated_class(options, ::AlternateValue)
      end

      def ignores_project?
        ::AlternateValue::ALWAYS_COMMUNITY.include?( annotated_class )
      end

      def community_project_id_facet
        return nil if @project_id.nil?

        if @project_id
          if !ignores_project?
            return table[:project_id].eq(project_id)
          end
        end
        nil
      end

      # @return [Arel::Node, nil]
      def matching_value
        value.blank? ? nil : table[:value].eq(value)
      end

      # @return [Arel::Node, nil]
      def matching_language_id
        language_id.blank? ? nil : table[:language_id].eq(language_id)
      end

      # @return [Arel::Node, nil]
      def matching_type
        type.blank? ? nil : table[:type].eq(type)
      end

      # @return [Arel::Node, nil]
      def matching_alternate_value_object_attribute
        alternate_value_object_attribute.blank? ? nil : table[:alternate_value_object_attribute].eq(alternate_value_object_attribute)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          Queries::Annotator.annotator_params(options, ::AlternateValue),
          matching_value,
          matching_language_id,
          matching_type,
          matching_alternate_value_object_attribute,
          community_project_id_facet,
        ].flatten.compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::AlternateValue.where(and_clauses)
        else
          ::AlternateValue.all
        end
      end

      # @return [Arel::Table]
      def table
        ::AlternateValue.arel_table
      end
    end
  end
end
