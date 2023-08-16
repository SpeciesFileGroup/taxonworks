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

        :local_identifiers,
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
      end

      def sqed_depiction_id
        [@sqed_depiction_id].flatten.compact
      end

      # TODO: will need to consider moving Identifies out of base class
      # because of edge cases like this (less inheritence, more composition)
      # applies to CO, not here 
      def local_identifiers_facet
        nil
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
