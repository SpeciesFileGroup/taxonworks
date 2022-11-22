module Queries
  module SqedDepiction
    class Filter < Queries::Query
      include Queries::Helpers
      include Queries::Concerns::Users

      COLLECTION_OBJECT_FILTER_PARAMS = %w{
       collecting_event
       taxon_determinations
       with_buffered_determinations
       with_buffered_collecting_event
       with_buffered_other_labels
       identifiers
       local_identifiers
      }

      attr_accessor :collection_object_filter_params

      attr_accessor :recent

      def initialize(params)
        @recent = params[:recent]
        @collection_object_filter_params = params.permit(COLLECTION_OBJECT_FILTER_PARAMS).to_h.select{|k,v| COLLECTION_OBJECT_FILTER_PARAMS.include?(k) ? k : nil}

        set_user_dates(params)
      end

      # @return [Arel::Table]
      def table
        ::SqedDepiction.arel_table
      end

      def base_query
        ::SqedDepiction.select('sqed_depictions.*')
      end

      def collection_object_query_facet
        q = ::Queries::CollectionObject::Filter.new(collection_object_filter_params).all
        ::SqedDepiction.joins(:collection_object).where(collection_objects: q)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = base_and_clauses

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Array]
      def base_and_clauses
        clauses = []
        clauses += [ ]
        clauses.compact!
        clauses
      end

      def base_merge_clauses
        clauses = []

        clauses += [
          created_updated_facet,  # See Queries::Concerns::Users
          collection_object_query_facet,
        ]

        clauses.compact!
        clauses
      end

      # @return [ActiveRecord::Relation]
      def merge_clauses
        clauses = base_merge_clauses
        return nil if clauses.empty?
        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses
        # q = nil
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::SqedDepiction.where(a).distinct
        elsif b
          q = b
        else
          q = ::SqedDepiction.all
        end

        # TODO: needs to go, orders mess with chaining.
        q = q.order(updated_at: :desc) if recent
        q
      end
    end

  end
end
