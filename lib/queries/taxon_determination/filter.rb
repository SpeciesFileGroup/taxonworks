module Queries
  module TaxonDetermination
    class Filter < Query::Filter

      # all Arrays
      attr_accessor :biological_collection_object_ids, :otu_ids, :determiner_ids

      def initialize(params = {})
        @otu_ids = params[:otu_ids] || []
        @biological_collection_object_ids = params[:biological_collection_object_ids]

        if !params[:collection_object_id].blank?
          @biological_collection_object_ids ||= []
          @biological_collection_object_ids.push(params[:collection_object_id])
        end

        @determiner_ids = params[:determiner_ids]

        @otu_ids.push(params[:otu_id]) unless params[:otu_id].blank?
        @biological_collection_object_ids ||= []
        @determiner_ids ||= []
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          matching_otu_ids,
          matching_biological_collection_object_ids,
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end

        a
      end

      def matching_otu_ids
        otu_ids.empty? ? nil : table[:otu_id].eq_any(otu_ids)
      end

      def matching_biological_collection_object_ids
        biological_collection_object_ids.empty? ? nil : table[:biological_collection_object_id].eq_any(biological_collection_object_ids)
      end

      def matching_determiner_ids
        determiner_ids.empty? ? nil : roles_table[:person_id].eq_any(determiner_ids)
      end

      # @return [String]
      def where_sql
        return ::TaxonDetermination.none if and_clauses.nil?
        and_clauses.to_sql
      end

      # TODO: Ugh, handle join more cleanly
      def all
        if determiner_ids.empty?
          base_query.where(where_sql).distinct
        else
          base_query.joins(:roles).where(where_sql).where( roles_table[:person_id].eq_any(determiner_ids).to_sql )
        end
      end

      # @return [Arel::Table]
      def roles_table
        ::Role.arel_table
      end

    end
  end
end
