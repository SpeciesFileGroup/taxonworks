module Queries
  module AlternateValue 

    # !! does not inherit from base query
    class Filter 

      # General annotator options handling 
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to AlternateValue
      attr_accessor :value, :language_id, :type, :alternate_value_object_attribute

      def initialize(params)
        @value = params[:value]
        @language_id = params[:language_id]
        @type = params[:type]
        @alternate_value_object_attribute = params[:alternate_value_object_attribute]
        @options = params.permit(:created_after, :created_before, on: [], by: [], id: []) 
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          Queries::Annotator.annotator_params(options, ::AlternateValue),
          matching_value,
          matching_language_id,
          matching_type,
          matching_alternate_value_object_attribute
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
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
      def all
        if a = and_clauses
          ::AlternateValue.where(and_clauses)
        else
          ::AlternateValue.none
        end
      end

      # @return [Arel::Table]
      def table
        ::AlternateValue.arel_table
      end
    end
  end
end
