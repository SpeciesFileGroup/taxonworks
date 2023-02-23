module Queries
  module Citation

    class Filter < Query::Filter
      include Queries::Helpers

      include Concerns::Polymorphic
      polymorphic_klass(::Citation)

      PARAMS = [
        *::Citation.related_foreign_keys.map(&:to_sym),
        :citation_id,
        :citation_object_id,
        :citation_object_type,
        :source_id,
        :is_original,
        citation_id: [],
        citation_object_id: [],
        citation_object_type: [],
      ].freeze

      # Array, Integer
      attr_accessor :citation_object_type

      attr_accessor :citation_object_id

      attr_accessor :source_id

      # Boolean
      attr_accessor :is_original

      # @params params [Hash]
      #   already Permitted params, or new Hash
      def initialize(query_params)
        super

        @citation_id = params[:citation_id]
        @citation_object_id = params[:citation_object_id]
        @citation_object_type = params[:citation_object_type]
        @is_original = params[:is_original]
        @source_id = params[:source_id]

        set_polymorphic_params(params)
      end

      def citation_object_type
        [@citation_object_type].flatten.compact
      end

      def citation_object_id
        [@citation_object_id].flatten.compact
      end

      def source_id
        [@source_id].flatten.compact
      end

      def citation_id
        [@citation_id].flatten.compact
      end

      def citation_object_type_facet
        return nil if citation_object_type.empty?
        table[:citation_object_type].eq_any(citation_object_type)
      end

      def citation_object_id_facet
        return nil if citation_object_id.empty?
        table[:citation_object_id].eq_any(citation_object_id)
      end

      def source_id_facet
        return nil if source_id.empty?
        table[:source_id].eq_any(source_id)
      end

      def is_original_facet
        is_original.blank? ? nil : table[:is_original].eq(is_original)
      end

      def and_clauses
        [
          citation_object_type_facet,
          citation_object_id_facet,
          source_id_facet,
          is_original_facet
        ]
      end

    end
  end
end
