module Queries
  module AssertedDistribution

    # !! does not inherit from base query
    class Filter

      include Queries::Concerns::Citations

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :otu_id

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :geographic_area_id

      attr_accessor :wkt

      attr_accessor :geo_json

      # Add citations extension

      # @param sourceid [Array, Integer, String]
      # @return [Array]
      # attr_accessor :source_id

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      # attr_accessor :is_original

      # TODO: replicate the TaxonName Parenthood params here
      # attr_accessor ancestor

      # TODO add spatial option for ancestor
      # @param attr_accessor ancestor_scope [String, Symbol, nil]
      # @return [Symbol, nil]
      #   `spatial` - treat spatial
      #   `parent` - use closure tree (parenthood)
      #   `expanded` - start with spatial, then for each spatial use parent
      #   `inverse_expanded` - start with parent, then for each use spatial (only make sense for non-spatial parents with some spatial children)

      # @return [Boolean, nil]
      # @params recent ['true', 'false', nil]
      attr_accessor :recent

      def initialize(params)
        @otu_id = params[:otu_id]
        @geographic_area_id = params[:geographic_area_id]

        @recent = params[:recent].blank? ? nil : params[:recent].to_i

        @wkt = params[:wkt]
        @geo_json = params[:geo_json]

        set_citations_params(params)
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      # @return [Arel::Table]
      def table
        ::AssertedDistribution.arel_table
      end

      def asserted_distribution_attribute_equals(attribute)
        a = send(attribute)
        if a
          return a.empty? ? nil : table[attribute].eq_any(a)
        end
        nil
      end

      def wkt_facet
        return nil if wkt.nil?

        i = ::GeographicItem.joins(:geographic_areas).where(::GeographicItem.contained_by_wkt_sql(wkt))
        j = ::GeographicArea.joins(:geographic_items).where(geographic_items: i)
        k = ::GeographicArea.descendants_of(j)

        ::AssertedDistribution.where(geographic_area: j).or.where(geographic_area: k)
      end

    # def geo_json_facet
    #   return nil if wkt.nil?

    #   i = ::GeographicItem.joins(:geographic_areas).where(::GeographicItem.contained_by_wkt_sql(wkt))
    #   j = ::GeographicArea.joins(:geographic_items).where(geographic_items: i)
    #   k = ::GeographicArea.descendants_of(j)

    #   ::AssertedDistribution.where(geographic_area: j).or.where(geographic_area: k)
    # end

     # Shape is a Hash in GeoJSON format
      def geo_json_facet
        return nil if geo_json.nil?
        if i = spatial_query

          j = ::GeographicArea.joins(:geographic_items).where(geographic_items: i)
          k = ::GeographicArea.descendants_of(j)

          return ::AssertedDistribution.where(geographic_area: j).or.where(geographic_area: k)
        else
          return nil
        end
      end

      def spatial_query
        if geometry = RGeo::GeoJSON.decode(geo_json)
          case geometry.geometry_type.to_s
          when 'Point'
            # TODO
            # radius = WHAT?
            ::GeographicItem.within_radius_of_wkt_sql(geometry.to_s, radius ) # TODO: FIX THIS, radius is not defined
          when 'Polygon', 'MultiPolygon'
            ::GeographicItem.contained_by_wkt_sql(geometry.to_s)
          else
            nil
          end
        else
          nil
        end
      end


      def base_and_clauses
        clauses = []
        clauses += [
          asserted_distribution_attribute_equals(:otu_id),
          asserted_distribution_attribute_equals(:geographic_area_id),
        ].compact
      end

      def base_merge_clauses
        clauses = []
        clauses +=
          [
            wkt_facet,
            geo_json_facet,
          ].compact
      end

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
      def and_clauses
        clauses = base_and_clauses
        return nil if clauses.empty?
        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def all
        a = and_clauses
        b = merge_clauses
        q = nil
        if a && b
          q = b.where(a).distinct
        elsif a
          q =  ::AssertedDistribution.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::AssertedDistribution.all
        end

        q = q.order(updated_at: :desc).limit(recent) if recent
        q
      end

      protected

    end
  end
end
