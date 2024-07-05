module Queries
  module TaxonDetermination
    class Filter < Query::Filter

      PARAMS = [
        :collection_object_id,
        :otu_id,
        :taxon_determination_id,

        taxon_determination_object_type: [],
        taxon_determination_object_id: [],
        collection_object_id: [],
        determiner_id: [],
        otu_id: [],
        taxon_determination_id: [],
      ].freeze

      # all Arrays
      attr_accessor :taxon_determination_id
      attr_accessor :collection_object_id
      attr_accessor :otu_id
      attr_accessor :determiner_id
      attr_accessor :taxon_determination_object_type
      attr_accessor :taxon_determination_object_id

      def initialize(query_params = {})
        super

        @collection_object_id = params[:collection_object_id]
        @determiner_id = params[:determiner_id]
        @otu_id = params[:otu_id]
        @taxon_determination_id = params[:taxon_determination_id]
        @taxon_determination_object_id = params[:taxon_determination_object_id]
        @taxon_determination_object_type = params[:taxon_determination_object_type]
      end

      def taxon_determination_id
        [@taxon_determination_id].flatten.compact.uniq
      end

      def otu_id
        [@otu_id].flatten.compact.uniq
      end

      def collection_object_id
        [@collection_object_id].flatten.compact.uniq
      end

      def taxon_determination_object_id
        [@taxon_determination_object_id].flatten.compact.uniq
      end

      def taxon_determination_object_type
        [@taxon_determination_object_type].flatten.compact
      end

      def determiner_id
        [@determiner_id].flatten.compact.uniq
      end

      def otu_id_facet
        return nil if otu_id.empty?
        table[:otu_id].in(otu_id)
      end

      def collection_object_id_facet
        return nil if collection_object_id.empty?
        table[:taxon_determination_object_id].in(collection_object_id)
        .and(table[:taxon_determination_object_type].eq('CollectionObject'))
      end

      def taxon_determination_object_type_facet
        return nil if taxon_determination_object_type.empty?
        table[:taxon_determination_object_type].in(taxon_determination_object_type)
      end

      def taxon_determination_object_id_facet
        return nil if taxon_determination_object_id.empty?
        table[:taxon_determination_object_id].in(taxon_determination_object_id)
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
          taxon_determination_object_id_facet,
          taxon_determination_object_type_facet
        ]
      end

    end
  end
end
