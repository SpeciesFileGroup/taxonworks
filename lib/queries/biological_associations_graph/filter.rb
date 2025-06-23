module Queries
  module BiologicalAssociationsGraph

    class Filter < Query::Filter
      include Queries::Concerns::Notes
      include Queries::Concerns::Tags
      include Queries::Concerns::Citations
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Geo

      PARAMS = [
        :biological_association_id,
        :biological_associations_graph_id,
        :biological_relationship_id,
        :geo_json,
        :geo_mode,
        :geo_shape_id,
        :geo_shape_type,
        :radius,
        :wkt,

        biological_association_id: [],
        biological_associations_graph_id: [],
        biological_relationship_id: [],
        geo_shape_id: [],
        geo_shape_type: [],
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

      attr_accessor :wkt
      attr_accessor :geo_json
      # Integer in Meters
      #   !! defaults to 100m
      attr_accessor :radius

      def initialize(query_params)
        super

        @biological_association_id = params[:biological_association_id]
        @biological_associations_graph_id = params[:biological_associations_graph_id]
        @biological_relationship_id = params[:biological_relationship_id]

        set_data_attributes_params(params)
        set_citations_params(params)
        set_notes_params(params)
        set_tags_params(params)
        set_geo_params(params)
      end

      def wkt_facet
        return nil if wkt.nil?
        from_wkt(wkt)
      end

      # Results are also returned from the otu and CO queries on subject/object.
      def from_wkt(wkt_shape)
        a = ::Queries::AssertedDistribution::Filter.new(
          wkt: wkt_shape, project_id:,
          asserted_distribution_object_type: 'BiologicalAssociationsGraph'
        )

        ::BiologicalAssociationsGraph
          .with(ad: a.all)
          .joins('JOIN ad ON ad.asserted_distribution_object_id = biological_associations_graphs.id')
      end

      def geo_json_facet
        return nil if geo_json.blank?
        return ::BiologicalAssociationsGraph.none if roll_call

        a = ::Queries::AssertedDistribution::Filter.new(
          geo_json:, project_id:, radius:,
          asserted_distribution_object_type: 'BiologicalAssociationsGraph'
        )

        ::BiologicalAssociationsGraph
          .with(ad: a.all)
          .joins('JOIN ad ON ad.asserted_distribution_object_id = biological_associations_graphs.id')
      end

      def biological_associations_graph_geo_facet
        return nil if geo_shape_id.empty? || geo_shape_type.empty? ||
          # TODO: this should raise an error(?)
          geo_shape_id.length != geo_shape_type.length
        return ::BiologicalAssociationsGraph.none if roll_call

        geographic_area_shapes, gazetteer_shapes = shapes_for_geo_mode

        a = biological_associations_graph_geo_facet_by_type(
          'GeographicArea', geographic_area_shapes
        )

        b = biological_associations_graph_geo_facet_by_type(
          'Gazetteer', gazetteer_shapes
        )

        if geo_mode == true # spatial
          i = ::Queries.union(::GeographicItem, [a,b])
          u = ::Queries::GeographicItem.st_union_text(i).to_a.first

          return from_wkt(u['st_astext'])
        end

        referenced_klass_union([a,b])
      end

      def biological_associations_graph_geo_facet_by_type(shape_string, shape_ids)
        case geo_mode
        when nil, false # exact, descendants
          ::BiologicalAssociationsGraph
            .joins("JOIN asserted_distributions ON asserted_distributions.asserted_distribution_object_id = biological_associations_graphs.id AND asserted_distributions.asserted_distribution_object_type = 'BiologicalAssociationsGraph'")
            .where(asserted_distributions: {
              asserted_distribution_shape: shape_ids
           })
        when true # spatial
          m = shape_string.tableize
          b = ::GeographicItem.joins(m.to_sym).where(m => shape_ids)
        end
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

        s << ::BiologicalAssociationsGraph.joins(:biological_associations_biological_associations_graphs)
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
          wkt_facet,
          geo_json_facet,
          biological_associations_graph_geo_facet,
        ]
      end
    end
  end
end
