module Queries
  module SqedDepiction
    class Filter < Query::Filter
      include Queries::Helpers

      COLLECTION_OBJECT_FILTER_PARAMS = %w{
       collecting_event
       taxon_determinations
       with_buffered_determinations
       with_buffered_collecting_event
       with_buffered_other_labels
       identifiers
       local_identifiers
      }.freeze

      attr_accessor :collection_object_filter_params

      def initialize(params)
        @collection_object_filter_params = params.permit(COLLECTION_OBJECT_FILTER_PARAMS)
          .to_h.select{|k,v| COLLECTION_OBJECT_FILTER_PARAMS.include?(k) ? k : nil}

        set_user_dates(params)
        super
      end

      def collection_object_query_facet
        q = ::Queries::CollectionObject::Filter.new(collection_object_filter_params).all
        ::SqedDepiction.joins(:collection_object).where(collection_objects: q)
      end

      def merge_clauses
        [ collection_object_query_facet ]
      end

    end
  end
