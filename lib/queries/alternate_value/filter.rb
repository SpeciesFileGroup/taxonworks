module Queries
  module AlternateValue
    class Filter < Query::Filter

      include Queries::Helpers
      include Concerns::Polymorphic
      polymorphic_klass(::AlternateValue)

      PARAMS = [
        *::AlternateValue.related_foreign_keys.map(&:to_sym),
        :alternate_value_id,
        :value,
        :language_id,
        :type,
        :alternate_value_object_attribute,
        alternate_value_id: []
      ].freeze

      # @return [Array]
      attr_accessor :alternate_value_id

      # Params specific to AlternateValue
      attr_accessor :value, :language_id, :type, :alternate_value_object_attribute

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @alternate_value_id = params[:alternate_value_id]
        @alternate_value_object_attribute = params[:alternate_value_object_attribute]
        @language_id = params[:language_id]
        @type = params[:type]
        @value = params[:value]
        set_polymorphic_params(params)
      end

      def alternate_value_id
        [@alternate_value_id].flatten.compact
      end

      def ignores_project?
        ::AlternateValue::ALWAYS_COMMUNITY.include?( polymorphic_type )
      end

      def community_project_id_facet
        return nil if project_id.empty?
        if !ignores_project?
          return table[:project_id].eq_any(project_id)
        end
        nil
      end

      def project_id_facet
        nil
      end

      def value_facet
        return nil if value.blank?
        table[:value].eq(value)
      end

      def language_id_facet
        return nil if language_id.blank?
        table[:language_id].eq(language_id)
      end

      def type_facet
        return nil if type.blank?
        table[:type].eq(type)
      end

      # @return [Arel::Node, nil]
      def alternate_value_object_attribute_facet
        alternate_value_object_attribute.blank? ? nil : table[:alternate_value_object_attribute].eq(alternate_value_object_attribute)
      end

      def and_clauses
        [
          value_facet,
          language_id_facet,
          type_facet,
          alternate_value_object_attribute_facet,
          community_project_id_facet,
        ]
      end

    end
  end
end
