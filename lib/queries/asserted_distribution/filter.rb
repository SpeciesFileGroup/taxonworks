module Queries
  module AssertedDistribution

    class Filter < Query::Filter

      include Queries::Concerns::Tags
      include Queries::Concerns::Notes
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Citations
      include Queries::Concerns::Geo
      include Queries::Concerns::Confidences

      PARAMS = [
        :asserted_distribution_id,
        :asserted_distribution_object_id,
        :asserted_distribution_object_type,
        :asserted_distribution_shape_type,
        :biological_association_id,
        :geo_shape_id,
        :geo_mode,
        :geo_shape_type,
        :descendants,
        :geo_json,
        :geographic_area_id,
        :geographic_item_id,
        :geographic_area_mode,
        :otu_id,
        :presence,
        :radius,
        :source_id,
        :shape_type,
        :taxon_name_id,
        :wkt,
        asserted_distribution_id: [],
        asserted_distribution_object_id: [],
        asserted_distribution_object_type: [],
        asserted_distribution_shape_type: [],
        biological_association_id: [],
        geo_shape_id: [],
        geo_shape_type: [],
        geographic_area_id: [],
        geographic_item_id: [],
        otu_id: [],
        source_id: [],
        taxon_name_id: []
      ].freeze

      # @param asserted_distribution_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :asserted_distribution_id

      # @param asserted_distribution_object_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :asserted_distribution_object_id

      # @param asserted_distribution_object_type [Array, Integer, String]
      # @return [Array]
      attr_accessor :asserted_distribution_object_type

      # @param biological_association_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :biological_association_id

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :otu_id

      # @param geographic_area_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :geographic_area_id

      # @param geographic_item_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :geographic_item_id

      # @return [Boolean, nil]
      #   How to treat GeographicAreas
      #     nil - non-spatial match by only those records matching the geographic_area_id exactly
      #     true - spatial match
      #     false - non-spatial match (descendants)
      attr_accessor :geographic_area_mode

      attr_accessor :wkt

      attr_accessor :geo_json

      # @return [Boolean, nil]
      #   true - Return AssertedDistributions where the OTU is asserted as present according to the Source
      #   false - Return AssertedDistributions where the OTU is asserted as absent according to the Source
      #   nil - both
      attr_accessor :presence

      # @return [Array]
      # @param [taxon name ids, nil]
      #   all Otus matching these taxon names
      attr_accessor :taxon_name_id

      # @param source_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :source_id

      # @return [Boolean, nil]
      #  true - include descendants of taxon_name_id in scope
      #  false, nil - only exact matches
      attr_accessor :descendants

      # Integer in Meters
      #   !! defaults to 100m
      attr_accessor :radius

      # @return [Array]
      attr_accessor :asserted_distribution_shape_type

      def initialize(query_params)
        super
        @asserted_distribution_id =
          integer_param(params, :asserted_distribution_id)
        @asserted_distribution_object_id =
          integer_param(params, :asserted_distribution_object_id)
        @asserted_distribution_object_type =
          params[:asserted_distribution_object_type]
        @biological_association_id =
          integer_param(params, :biological_association_id)
        @descendants = boolean_param(params, :descendants)
        @geo_json = params[:geo_json]
        @geographic_area_id = integer_param(params,:geographic_area_id)
        @geographic_item_id = integer_param(params, :geographic_item_id)
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)
        @otu_id = integer_param(params, :otu_id)
        @presence = boolean_param(params, :presence)
        @radius = params[:radius].presence || 100.0
        @asserted_distribution_shape_type =
          params[:asserted_distribution_shape_type]
        @source_id = integer_param(params, :source_id)
        @taxon_name_id = integer_param(params, :taxon_name_id)
        @wkt = params[:wkt]

        set_confidences_params(params)
        set_citations_params(params)
        set_data_attributes_params(params)
        set_geo_params(params)
        set_notes_params(params)
        set_tags_params(params)
      end

      def asserted_distribution_id
        [@asserted_distribution_id].flatten.compact
      end

      def asserted_distribution_object_id
        [@asserted_distribution_object_id].flatten.compact
      end

      def asserted_distribution_object_type
        [@asserted_distribution_object_type].flatten.compact
      end

      def biological_association_id
        [@biological_association_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      def geographic_item_id
        [@geographic_item_id].flatten.compact
      end

      def asserted_distribution_shape_type
        [@asserted_distribution_shape_type].flatten.compact
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def source_id
        [@source_id].flatten.compact
      end

      def presence_facet
        return nil if presence.nil?
        if presence
          table[:is_absent].eq_any(['f', nil]) # !! not eq_any()
        else
          table[:is_absent].eq('t')
        end
      end

      def wkt_facet
        return nil if wkt.nil?
        from_wkt(wkt)
      end

      def from_wkt(wkt_shape)
        a = self.class.geographic_areas_for_geographic_items(
          ::GeographicItem.covered_by_wkt_sql(wkt_shape)
        )
        b = self.class.gazetteers_for_geographic_items(
          ::GeographicItem.covered_by_wkt_sql(wkt_shape)
        )

        ::Queries.union(::AssertedDistribution, [a, b])
      end

      def self.from_geographic_items(geographic_items_sql)
        # TODO: can we combine GAs and GAZs *before* joining with
        # geographic_items_sql? That would save a spatial contains query.
        a = self.geographic_areas_for_geographic_items(geographic_items_sql)
        b = self.gazetteers_for_geographic_items(geographic_items_sql)

        ::Queries.union(::AssertedDistribution, [a,b])
      end

      def self.geographic_areas_for_geographic_items(geographic_items_sql)
        i = ::GeographicItem
          .joins(:geographic_areas)
          .where(geographic_items_sql)

        j = ::GeographicArea.joins(:geographic_items).merge(i).pluck(:id)

        # TODO: There are only 58 GAs with shape that have a descendant without
        # shape: could this be a lookup table instead?
        k = ::GeographicArea.descendants_of(j).pluck(:id) # Add children that might not be caught because they don't have shapes

        geographic_area_ids = (j + k).uniq
        if geographic_area_ids.empty?
          return ::AssertedDistribution.none
        end

        ::AssertedDistribution
          .where(asserted_distribution_shape_id: geographic_area_ids,
            asserted_distribution_shape_type: 'GeographicArea')
      end

      def self.gazetteers_for_geographic_items(geographic_items_sql)
        i = ::GeographicItem.joins(:gazetteers).where(geographic_items_sql)

        gazetteer_ids = ::Gazetteer
          .joins(:geographic_item).merge(i).pluck(:id)

        if gazetteer_ids.empty?
          return ::AssertedDistribution.none
        end

        ::AssertedDistribution
          .where(asserted_distribution_shape_id: gazetteer_ids,
            asserted_distribution_shape_type: 'Gazetteer')
      end

      # Shape is a Hash in GeoJSON format
      def geo_json_facet
        return nil if geo_json.nil?
        return ::AssertedDistribution.none if roll_call

        i = spatial_query
        return nil if i.nil?

        j = ::GeographicArea.joins(:geographic_items).where(geographic_items: i)

        # Expand to include all descendants of any spatial match!
        # We only care about areas actually used here.
        k = ::GeographicArea.joins(:asserted_distributions).descendants_of(j)

        ga_ids = ::GeographicArea.from("((#{j.to_sql}) UNION (#{k.to_sql})) as geographic_areas").distinct

        gz_ids = ::Gazetteer.joins(:geographic_item).where(geographic_item: i)

        return ::AssertedDistribution
          .where( asserted_distribution_shape: ga_ids )
          .where( asserted_distribution_shape_type: 'GeographicArea')
          .or(
            ::AssertedDistribution
              .where( asserted_distribution_shape: gz_ids )
              .where( asserted_distribution_shape_type: 'Gazetteer')
          )

      end

      # @return [GeographicItem scope]
      def spatial_query
        if geometry = RGeo::GeoJSON.decode(geo_json)
          case geometry.geometry_type.to_s
          when 'Point'
            a = ::GeographicItem
              .joins(:geographic_areas)
              .where(
                ::GeographicItem.within_radius_of_wkt_sql(geometry.to_s, radius)
              )
            b = ::GeographicItem
              .joins(:gazetteers)
              .where(
                ::GeographicItem.within_radius_of_wkt_sql(geometry.to_s, radius)
              )

            ::Queries.union(::GeographicItem, [a, b])
          when 'Polygon', 'MultiPolygon'
            a = ::GeographicItem
              .joins(:geographic_areas)
              .where(::GeographicItem.covered_by_wkt_sql(geometry.to_s))
            b = ::GeographicItem
              .joins(:gazetteers)
              .where(::GeographicItem.covered_by_wkt_sql(geometry.to_s))

            ::Queries.union(::GeographicItem, [a, b])
          else
            nil
          end
        else
          nil
        end
      end

      def asserted_distribution_object_facet
        return nil if asserted_distribution_object_type.length != 1 ||
          asserted_distribution_object_id.empty?

        table[:asserted_distribution_object_id]
          .in(asserted_distribution_object_id).and(
            table[:asserted_distribution_object_type]
              .eq(asserted_distribution_object_type.first)
          )
      end

      def asserted_distribution_object_type_facet
        return nil if asserted_distribution_object_type.empty?

        table[:asserted_distribution_object_type]
          .in(asserted_distribution_object_type)
      end

      def asserted_distribution_shape_type_facet
        return nil if asserted_distribution_shape_type.empty?

        table[:asserted_distribution_shape_type]
          .in(asserted_distribution_shape_type)
      end

      def asserted_distribution_geo_facet
        return nil if geo_shape_id.empty? || geo_shape_type.empty? ||
          # TODO: this should raise an error(?)
          geo_shape_id.length != geo_shape_type.length
        return ::AssertedDistribution.none if roll_call

        geographic_area_shapes, gazetteer_shapes = shapes_for_geo_mode

        a = asserted_distribution_geo_facet_by_type(
          'GeographicArea', geographic_area_shapes
        )

        b = asserted_distribution_geo_facet_by_type(
          'Gazetteer', gazetteer_shapes
        )

        if geo_mode != true # exact or descendants
          return referenced_klass_union([a,b])
        end

        # Spatial.
        i = ::Queries.union(::GeographicItem, [a,b])
        self.class.from_geographic_items(
          ::GeographicItem.covered_by_geographic_items_sql(i)
        )
      end

      def asserted_distribution_geo_facet_by_type(shape_string, shape_ids)
        b = nil

        case geo_mode
        when nil, false # exact, descendants
          b = ::AssertedDistribution
            .where(asserted_distribution_shape: shape_ids)
        when true # spatial
          m = shape_string.tableize
          b = ::GeographicItem.joins(m.to_sym).where(m => shape_ids)
        end

        b
      end

      def otu_id_facet
        return nil if otu_id.empty?
        table[:asserted_distribution_object_type].eq('Otu').and(
          table[:asserted_distribution_object_id].in(otu_id)
        )
      end

      def biological_association_id_facet
        return nil if biological_association_id.empty?
        table[:asserted_distribution_object_type].eq('BiologicalAssociation')
          .and(table[:asserted_distribution_object_id]
            .in(biological_association_id)
          )
      end

      def geographic_item_id_facet
        return nil if geographic_item_id.empty?
        ::GeographicArea.joins(:geographic_areas_geographic_items).where(
          geographic_areas_geographic_items: {geographic_item_id:}
        )
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?
        if descendants
          h = Arel::Table.new(:taxon_name_hierarchies)
          o = Arel::Table.new(:otus)

          j = o.join(h, Arel::Nodes::InnerJoin).on(o[:taxon_name_id].eq(h[:descendant_id]))
          z = h[:ancestor_id].in(taxon_name_id)

          ::AssertedDistribution.with_otus.joins(j.join_sources).where(z)
        else
          ::AssertedDistribution.with_otus.where(otus: {taxon_name_id:})
        end
      end

      def source_id_facet
        return nil if source_id.empty?

        ::AssertedDistribution
          .joins(:citations)
          .where(citations: { source_id: })
          .distinct
      end

      def otu_query_facet
        return nil if otu_query.nil?
        s = 'WITH query_otu_ad AS (' + otu_query.all.to_sql + ') ' +
          ::AssertedDistribution
          .joins("JOIN query_otu_ad AS query_otu_ad1 ON query_otu_ad1.id = asserted_distributions.asserted_distribution_object_id AND asserted_distributions.asserted_distribution_object_type = 'Otu'")
          .to_sql
        ::AssertedDistribution.from('(' + s + ') as asserted_distributions')
      end

      def observation_query_facet
        return nil if observation_query.nil?
        ::AssertedDistribution
          .with(obs: observation_query.all)
          .joins("JOIN obs ON obs.id = asserted_distributions.asserted_distribution_object_id AND asserted_distributions.asserted_distribution_object_type = 'Observation'")
          .distinct
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?
        s = 'WITH query_tn_ad AS (' + taxon_name_query.all.to_sql + ') ' +
          ::AssertedDistribution
          .with_otus
          .joins('JOIN query_tn_ad as query_tn_ad1 on query_tn_ad1.id = otus.taxon_name_id')
          .to_sql
        ::AssertedDistribution.from('(' + s + ') as asserted_distributions').distinct
      end

      def biological_association_query_facet
        return nil if biological_association_query.nil?
        # On the BA itself.
        a = ::AssertedDistribution
          .with(ba: biological_association_query.all)
          .joins("JOIN ba ON ba.id = asserted_distributions.asserted_distribution_object_id AND asserted_distributions.asserted_distribution_object_type = 'BiologicalAssociation'")

        # On subject/object of the BA.
        b = ::AssertedDistribution
          .with(ba: biological_association_query.all)
          .joins("JOIN ba ON asserted_distributions.asserted_distribution_object_id = ba.biological_association_subject_id AND ba.biological_association_subject_type = 'Otu'")

        c = ::AssertedDistribution
          .with(ba: biological_association_query.all)
          .joins("JOIN ba ON asserted_distributions.asserted_distribution_object_id = ba.biological_association_object_id AND ba.biological_association_object_type = 'Otu'")

        # On a graph containing the BA.
        d = ::AssertedDistribution
          .with(ba: biological_association_query.all)
          .joins("JOIN biological_associations_graphs ON biological_associations_graphs.id = asserted_distributions.asserted_distribution_object_id AND asserted_distributions.asserted_distribution_object_type = 'BiologicalAssociationsGraph' " \
          "JOIN biological_associations_biological_associations_graphs ON biological_associations_biological_associations_graphs.biological_associations_graph_id = biological_associations_graphs.id JOIN ba ON ba.id = biological_associations_biological_associations_graphs.biological_association_id")

          referenced_klass_union([a,b,c,d])
      end

      def dwc_occurrence_query_facet
        return nil if dwc_occurrence_query.nil?

         s = ::AssertedDistribution
          .with(query_dwc_ad: dwc_occurrence_query.all.select(:dwc_occurrence_object_id, :dwc_occurrence_object_type, :id))
          .joins(:dwc_occurrence)
          .joins('JOIN query_dwc_ad as query_dwc_ad1 on query_dwc_ad1.id = dwc_occurrences.id')
          .to_sql

        ::AssertedDistribution.from('(' + s + ') as asserted_distributions').distinct
      end

      def and_clauses
        [
          biological_association_id_facet,
          otu_id_facet,
          presence_facet,
          asserted_distribution_shape_type_facet,
          asserted_distribution_object_type_facet,
          asserted_distribution_object_facet,
        ]
      end

      def merge_clauses
        [
          dwc_occurrence_query_facet,
          biological_association_query_facet,
          geo_json_facet,
          otu_query_facet,
          taxon_name_query_facet,
          source_id_facet,

          asserted_distribution_geo_facet,
          geographic_item_id_facet,
          taxon_name_id_facet,
          observation_query_facet,
          wkt_facet,
        ]
      end

    end
  end
end
