module Queries
  module TaxonDetermination
    class Filter < Query::Filter

      PARAMS = [
        :collection_object_id,
        :otu_id,
        otu_id: [],
        determiner_id: [],
        collection_object_id: [],
      ]

      # all Arrays
      attr_accessor :collection_object_id
      attr_accessor :otu_id
      attr_accessor :determiner_id

      def initialize(params = {})
        @otu_id = params[:otu_id]
        @collection_object_id = params[:collection_object_id]
        @determiner_id = params[:determiner_id]
        super
      end

      def otu_id
        [@otu_id].flatten.compact.uniq
      end

      def collection_object_id
        [@collection_object_id].flatten.compact.uniq
      end

      def determiner_id
        [@determiner_id].flatten.compact.uniq
      end
      
      def otu_id_facet
        return nil if otu_id.empty?
        table[:otu_id].eq_any(otu_id)
      end

      def collection_object_id_facet
        return nil if collection_object_id.empty?
         table[:biological_collection_object_id].eq_any(collection_object_id)
      end

      def determiner_id_facet
        return nil if determiner_id.empty?
        ::TaxonDetermination.joins(:determiner_roles).where(
          roles: {person_id: determiner_id}
        )
      end

      # @return [Arel::Table]
      def roles_table
        ::Role.arel_table
      end

      def merge_clauses
        [
          determiner_id_facet
        ]
      end

      def and_clauses
        [
          otu_id_facet,
          collection_object_id_facet,
        ]
      end

    end
  end
end
