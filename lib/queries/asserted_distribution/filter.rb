module Queries
  module AssertedDistribution

    class Filter < Query::Filter

      include Queries::Concerns::Tags
      include Queries::Concerns::Notes
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Citations

      PARAMS = [
        :asserted_distribution_id,
        :descendants,
        :geo_json,
        :geographic_area_id,
        :geographic_area_mode,
        :otu_id,
        :presence,
        :radius,
        :taxon_name_id,
        :wkt,
        asserted_distribution_id: [],
        geographic_area_id: [],
        otu_id: [],
        taxon_name_id: [],
      ].freeze

      # @param asserted_distribution_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :asserted_distribution_id

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :otu_id

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :geographic_area_id

      # @return [Boolean, nil]
      #   How to treat GeographicAreas
      #     nil - non-spatial match by only those records matching the geographic_area_id exactly
      #     true - spatial match
      #     false - non-spatial match (descendants)
      attr_accessor :geographic_area_mode

      attr_accessor :wkt

      attr_accessor :geo_json

      # @return [Boolean, nil]
      #   nil - both
      #   true - only 't'
      #   false - only 'f'
      attr_accessor :presence

      # @return Array
      # @param [taxon name ids, nil]
      #   all Otus matching these taxon names
      attr_accessor :taxon_name_id

      # @return [Boolean, nil]
      #  true - include descendants of taxon_name_id in scope
      #  false, nil - only exact matches
      attr_accessor :descendants

      # Integer in Meters
      #   !! defaults to 100m
      attr_accessor :radius

      def initialize(query_params)
        super
        @asserted_distribution_id = params[:asserted_distribution_id]
        @descendants = boolean_param(params, :descendants)
        @geo_json = params[:geo_json]
        @geographic_area_id = params[:geographic_area_id]
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)
        @otu_id = params[:otu_id]
        @presence = boolean_param(params, :presence)
        @radius = params[:radius].presence || 100.0
        @taxon_name_id = params[:taxon_name_id]
        @wkt = params[:wkt]

        set_citations_params(params)
        set_data_attributes_params(params)
        set_notes_params(params)
        set_tags_params(params)
      end

      def asserted_distribution_id
        [@asserted_distribution_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def presence_facet
        return nil if presence.nil?
        if presence
          table[:is_absent].eq_any(['f', nil])
        else
          table[:is_absent].eq('t')
        end
      end

      def wkt_facet
        return nil if wkt.nil?
        from_wkt(wkt)
      end

      def from_wkt(wkt_shape)

        i = ::GeographicItem.joins(:geographic_areas).where(::GeographicItem.contained_by_wkt_sql(wkt_shape))

        j = ::GeographicArea.joins(:geographic_items).where(geographic_items: i)
        k = ::GeographicArea.descendants_of(j) # Add children that might not be caught because they don't have a shapes

        l = ::GeographicArea.from("((#{j.to_sql}) UNION (#{k.to_sql})) as geographic_areas").distinct

        s = 'WITH query_wkt_ad AS (' + l.all.to_sql + ') ' +
          ::AssertedDistribution
          .joins('JOIN query_wkt_ad as query_wkt_ad1 on query_wkt_ad1.id = asserted_distributions.geographic_area_id')
          .to_sql

        ::AssertedDistribution.from('(' + s + ') as asserted_distributions')
      end

      # Shape is a Hash in GeoJSON format
      def geo_json_facet
        return nil if geo_json.nil?

        if a = RGeo::GeoJSON.decode(geo_json)

          # # all spatial records
          i = spatial_query(a.geometry_type.to_s, a.to_s)

       #  # All spatial records
       #  j = ::GeographicArea.joins(:geographic_items).where(geographic_items: i)

       #  # Expand to include all descendants of any spatial match!
       #  k = ::GeographicArea.descendants_of(j)

       #  l = ::GeographicArea.from("((#{j.to_sql}) UNION (#{k.to_sql})) as geographic_areas").distinct

          return i #  ::AssertedDistribution.where( geographic_area: l )
        else
          return nil
        end
      end

      def spatial_query(geometry_type, wkt)
        case geometry_type
        when 'Point'
          ::AssertedDistribution
            .joins(:geographic_items)
            .where(::GeographicItem.within_radius_of_wkt_sql(wkt, radius ))
        when 'Polygon', 'MultiPolygon'
          ::AssertedDistribution
            .joins(:geographic_items)
            .where(::GeographicItem.contained_by_wkt_sql(wkt))
        else
          nil
        end
      end

 #    # @return [GeographicItem scope]
 #    def spatial_query
 #      if geometry = RGeo::GeoJSON.decode(geo_json)
 #        case geometry.geometry_type.to_s
 #        when 'Point'
 #          ::GeographicItem.where(::GeographicItem.within_radius_of_wkt_sql(geometry.to_s, radius ) )
 #        when 'Polygon', 'MultiPolygon'
 #          ::GeographicItem.where(::GeographicItem.contained_by_wkt_sql(geometry.to_s))
 #        else
 #          nil
 #        end
 #      else
 #        nil
 #      end
 #    end

      def geographic_area_id_facet
        return nil if geographic_area_id.empty?

        a = nil

        case geographic_area_mode
        when nil, true # exact and spatial start the same
          a = ::GeographicArea.where(id: geographic_area_id)
        when false # descendants
          a = ::GeographicArea.descendants_of_any(geographic_area_id)
        end

        b = nil # from AssertedDistributions

        case geographic_area_mode
        when nil, false # exact, descendants
          b = ::AssertedDistribution.where(geographic_area: a)
        when true # spatial
          i = ::GeographicItem.joins(:geographic_areas).where(geographic_areas: a) # .unscope
          wkt_shape = ::GeographicItem.st_union(i).to_a.first['collection'].to_s # todo, check
          return from_wkt(wkt_shape)
        end

        b
      end

      def otu_id_facet
        return nil if otu_id.empty?
        table[:otu_id].eq_any(otu_id)
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?
        if descendants
          h = Arel::Table.new(:taxon_name_hierarchies)
          o = Arel::Table.new(:otus)

          j = o.join(h, Arel::Nodes::InnerJoin).on(o[:taxon_name_id].eq(h[:descendant_id]))
          z = h[:ancestor_id].eq_any(taxon_name_id)

          ::AssertedDistribution.joins(:otu).joins(j.join_sources).where(z)
        else
          ::AssertedDistribution.joins(:otu).where(otus: {taxon_name_id: taxon_name_id})
        end
      end

      def otu_query_facet
        return nil if otu_query.nil?
        s = 'WITH query_otu_ad AS (' + otu_query.all.to_sql + ') ' +
          ::AssertedDistribution
          .joins('JOIN query_otu_ad as query_otu_ad1 on query_otu_ad1.id = asserted_distributions.otu_id')
          .to_sql
        ::AssertedDistribution.from('(' + s + ') as asserted_distributions')
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?
        s = 'WITH query_tn_ad AS (' + taxon_name_query.all.to_sql + ') ' +
          ::AssertedDistribution
          .joins(:otu)
          .joins('JOIN query_tn_ad as query_tn_ad1 on query_tn_ad1.id = otus.taxon_name_id')
          .to_sql
        ::AssertedDistribution.from('(' + s + ') as asserted_distributions')
      end

      def biological_association_query_facet
        return nil if biological_association_query.nil?
        s = 'WITH query_ad_ba AS (' + biological_association_query.all.to_sql + ') '

        a = ::AssertedDistribution
          .joins("JOIN query_ad_ba as query_ad_ba1 on asserted_distributions.otu_id = query_ad_ba1.biological_association_subject_id AND query_ad_ba1.biological_association_subject_type = 'Otu'").to_sql

        b = ::AssertedDistribution
          .joins("JOIN query_ad_ba as query_ad_ba2 on asserted_distributions.otu_id = query_ad_ba2.biological_association_object_id AND query_ad_ba2.biological_association_object_type = 'Otu'").to_sql

        s << ::AssertedDistribution.from("((#{a}) UNION (#{b})) as asserted_distributions").to_sql

        ::AssertedDistribution.from('(' + s + ') as asserted_distributions')
      end

      def and_clauses
        [
          otu_id_facet,
          presence_facet,
        ]
      end

      def merge_clauses
        [
          biological_association_query_facet,
          geo_json_facet,
          otu_query_facet,
          taxon_name_query_facet,

          geographic_area_id_facet,
          taxon_name_id_facet,
          wkt_facet,
        ]
      end

    end
  end
end
