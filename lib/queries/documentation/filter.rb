module Queries
  module Documentation
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Documentation)

      PARAMS = [
        *::Documentation.related_foreign_keys.map(&:to_sym), 
        :documentation_id,
        :documentation_object_id,
        :documentation_object_type,
        documentation_id: [],
      ].freeze

      attr_accessor :documentation_id

      attr_accessor :documentation_object_id

      attr_accessor :documentation_object_type

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @documentation_id = params[:documentation_id]
        @documentation_object_id = params[:documentation_object_id]
        @documentation_object_type = params[:documentation_object_type]

        set_polymorphic_params(params)
      end

      def documentation_id
        [@documentation_id].flatten.compact
      end

      def documentation_object_type
        [@documentation_object_type].flatten.compact
      end

      def documentation_object_id
        [@documentation_object_id].flatten.compact
      end

      def documentation_object_type_facet
        return nil if documentation_object_type.empty?
        table[:documentation_object_type].in(documentation_object_type)
      end

      def documentation_object_id_facet
        return nil if documentation_object_id.empty?
        table[:documentation_object_id].in(documentation_object_id)
      end

      # If we add merge_clauses then we likely have
      # to deal with excluding the `xml` field from distinct+intersection calls
      # via a custom base_query field.

      def and_clauses
        [
          documentation_object_id_facet,
          documentation_object_type_facet
        ]
      end

    end
  end
end