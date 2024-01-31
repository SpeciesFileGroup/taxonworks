module Queries
  module SqedDepiction
    class Filter < Query::Filter
      include Queries::Helpers

      COLLECTION_OBJECT_FILTER_PARAMS = [
        :collecting_event,
        :taxon_determinations,
        :with_buffered_determinations,
        :with_buffered_collecting_event,
        :with_buffered_other_labels,

        :identifier,
        :identifier_end,
        :identifier_exact,
        :identifier_start,
        :identifier_type,
        :identifiers,
        :local_identifiers,
        :global_identifiers,
        :match_identifiers,
        :match_identifiers_delimiter,
        :match_identifiers_type,
        :namespace_id,
        identifier_type: [],
      ].freeze

      PARAMS = [
        *COLLECTION_OBJECT_FILTER_PARAMS,
        :sqed_depiction_id,
        sqed_depiction_id: [],
      ].freeze

      # @return Hash
      attr_accessor :base_collection_object_filter_params

      attr_accessor :sqed_depiction_id

      def initialize(query_params)
        super

        @sqed_depiction_id = params[:sqed_depiction_id]
        @base_collection_object_filter_params = params.select{|k,v| COLLECTION_OBJECT_FILTER_PARAMS.include?(k) ? k : nil}
        @params = @params.delete_if{|k,v| @base_collection_object_filter_params[k].present?}
        @no_identifier_clauses = true
      end

      def sqed_depiction_id
        [@sqed_depiction_id].flatten.compact
      end

      # TODO: use WITH
      def base_collection_object_query_facet
        q = ::Queries::CollectionObject::Filter.new(base_collection_object_filter_params).all
        ::SqedDepiction.joins(:collection_object).where(collection_objects: q)
      end

      def merge_clauses
        [ base_collection_object_query_facet ]
      end
    end
  end
end
