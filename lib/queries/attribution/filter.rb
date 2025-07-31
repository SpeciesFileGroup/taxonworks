module Queries
  module Attribution

    class Filter < Query::Filter
      include Concerns::Polymorphic
      polymorphic_klass(::Attribution)

      PARAMS = [
        *::Attribution.related_foreign_keys.map(&:to_sym),
        :attriution_id,
        :attribution_object_id,
        :attribution_object_type,
        attribution_id: [],
      ].freeze

      attr_accessor :attribution_id

            # @return Array
      attr_accessor :attribution_level_id

      # @return Array
      attr_accessor :attribution_object_type

      def initialize(query_params)
        super
        @attribution_id = params[:attribution_id]
        @attribution_object_type = params[:attribution_object_type]
        @attribution_object_id = params[:attribution_object_id]
        set_polymorphic_params(params)
      end

      def attribution_id
        [@attribution_id].flatten.compact
      end

      def attribution_object_type
        [@attribution_object_type].flatten.compact
      end

      def attribution_object_id
        [@attribution_object_id].flatten.compact
      end

      # @return [Arel::Node, nil]
      def attribution_object_type_facet
        attribution_object_type.empty? ? nil : table[:attribution_object_type].in(attribution_object_type)
      end

      # @return [Arel::Node, nil]
      def attribution_object_id_facet
        attribution_object_id.empty? ? nil : table[:attribution_object_id].in(attribution_object_id)
      end

      def and_clauses
        [
          attribution_object_type_facet,
          attribution_object_id_facet
        ]
      end

    end
  end
end
