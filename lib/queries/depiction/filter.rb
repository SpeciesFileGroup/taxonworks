module Queries
  module Depiction
    class Filter < Query::Filter
      include Queries::Concerns::Tags

      PARAMS = [
        :depiction_id,
        :depiction_object_id,
        :depiction_object_type,
        :image_id,
        depiction_id: [],
        depiction_object_id: [],
        depiction_object_type: [],
        image_id: [],
      ].freeze

      attr_accessor :depiction_id

      attr_accessor :image_id

      attr_accessor :depiction_object_id

      attr_accessor :depiction_object_type

      # @param params [Hash]
      def initialize(query_params)
        super

        @depiction_id = params[:depiction_id]
        @depiction_object_id = params[:depiction_object_id]
        @depiction_object_type = params[:depiction_object_type]
        @image_id = params[:image_id]

        set_tags_params(params)
      end

      def image_id
        [@image_id].flatten.compact
      end

      def depiction_id
        [@depiction_id].flatten.compact
      end

      def depiction_object_type
        [@depiction_object_type].flatten.compact
      end

      def depiction_object_id
        [@depiction_object_id].flatten.compact
      end

      def depiction_id_facet
        return nil if depiction_id.empty?
        table[:id].in(depiction_id)
      end

      def image_id_facet
        return nil if image_id.empty?
        table[:image_id].in(image_id)
      end

      def depiction_object_type_facet
        return nil if depiction_object_type.empty?
        table[:depiction_object_type].in(depiction_object_type)
      end

      def depiction_object_id_facet
        return nil if depiction_object_id.empty?
        table[:depiction_object_id].in(depiction_object_id)
      end

      # If we add merge_clauses then we likely have
      # to deal with excluding the `xml` field from distinct+intersection calls
      # via a custom base_query field.

      def and_clauses
        [
          depiction_id_facet,
          image_id_facet,
          depiction_object_id_facet,
          depiction_object_type_facet
        ]
      end

    end
  end
end
