module Queries
  module BiologicalAssociationsGraph

    class Filter < Query::Filter
      include Queries::Concerns::Notes
      include Queries::Concerns::Tags
      include Queries::Concerns::Citations
      include Queries::Concerns::DataAttributes

      PARAMS = [
        :biological_association_id,
        :biological_associations_graph_id,
        :biological_relationship_id,

        biological_association_id: [],
        biological_associations_graph_id: [],
        biological_relationship_id: [],
      ].freeze

      API_PARAM_EXCLUSIONS = [ ]

      # @param biological_associations_graph_id
      #   These biological association graphs
      attr_accessor :biological_associations_graph_id

      # @return [Array]
      #   one or more BiologicalAssociation#id
      # @param biological_association_id [Array, Integer]
      attr_accessor :biological_association_id

      # @return [Array]
      #   one or more biological relationship ID
      # See also exclude_taxon_name_relationship
      # @param biological_relationship_id [Array, Integer]
      attr_accessor :biological_relationship_id

      def initialize(query_params)
        super

        @biological_association_id = params[:biological_association_id]
        @biological_associations_graph_id = params[:biological_associations_graph_id]
        @biological_relationship_id = params[:biological_relationship_id]

        set_data_attributes_params(params)
        set_citations_params(params)
        set_notes_params(params)
        set_tags_params(params)
      end

      def biological_association_id
        [@biological_association_id].flatten.compact.uniq
      end

      def biological_relationship_id
        [@biological_relationship_id].flatten.compact.uniq
      end

      def biological_associations_graph_id
        [@biological_associations_graph_id].flatten.compact.uniq
      end

      def biological_associations_graph_id_facet
        return nil if biological_associations_graph_id.empty?
        table[:id].in(biological_associations_graph_id)
      end

      def biological_relationship_id_facet
        return nil if biological_relationship_id.empty?
        ::BiologicalAssociationsGraph.joins(biological_associations_biological_associations_graphs: [:biological_association])
        .where(biological_associations: { biological_association_relationship_id: biological_relationship_id }).distinct
      end

      def biological_association_id_facet
        return nil if biological_association_id.empty?
        ::BiologicalAssociationsGraph.joins(biological_associations_biological_associations_graphs: [:biological_association])
        .where(biological_associations_biological_associations_graphs: { biological_association_id: }).distinct
      end

      def biological_association_query_facet
        return nil if biological_association_query.nil?
        s = 'WITH query_ba_bag AS (' + biological_association_query.all.to_sql + ') '

        s << ::BiologicalAssociationGraph.joins(:biological_associations_biological_associations_graphs)
          .joins('JOIN query_ba_bag as query_ba_bag1 on biological_associations_biological_associations_graphs.biological_association_id = query_ba_bag1.id').to_sql

        ::BiologicalAssociation.from('(' + s + ') as biological_associations')
      end

      def and_clauses
        [ biological_associations_graph_id_facet ]
      end

      def merge_clauses
        [
          biological_association_id_facet,
          biological_relationship_id_facet,
        ]
      end
    end
  end
end
