module Queries
  module GeographicArea

    class Filter < Query::Filter

      PARAMS = [
        :containing_point,
        :geographic_area_id,
        :geographic_items,
        :name,
        geographic_area_id: []
      ].freeze

      # @return Array
      # @param name [String, Array]
      #   matches one or more named entities
      attr_accessor :name

      # @return Array
      # @param geographic_area_id [Integer, Array]
      attr_accessor :geographic_area_id

      # @param [String]
      #   WKT representation of a point.  All areas
      #     containing that point are returned
      #     e.g. `POINT(44 22)`
      attr_accessor :containing_point

      # @param geographic_items [Boolean]
      #   true - has shape
      #   false - has no shape
      #   nil - ignored
      attr_accessor :geographic_items

      def initialize(query_params)
        super
        @name = params[:name]
        @containing_point = params[:containing_point]
        @geographic_items = boolean_param(params, :geographic_items)
      end

      def name
        [@name].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      # Required, disable default facet
      def project_id_facet
        nil
      end

      def name_facet
        return nil if name.blank?
        table[:name].eq(name)
      end

      def containing_point_facet
        return nil if containing_point.nil?
        a = ::GeographicArea
          .joins(:geographic_items)
          .merge(::GeographicItem.polygons)
          .where(
            ::GeographicItem.st_covers_sql(
              ::GeographicItem.geography_as_geometry,
              ::GeographicItem.st_geom_from_text_sql(containing_point)
            )
          )

        b = ::GeographicArea
          .joins(:geographic_items)
          .merge(::GeographicItem.multi_polygons)
          .where(
            ::GeographicItem.st_covers_sql(
              ::GeographicItem.geography_as_geometry,
              ::GeographicItem.st_geom_from_text_sql(containing_point)
            )
          )

        referenced_klass_union([a,b])
      end

      def geographic_items_facet
        return nil if geographic_items.nil?
        if geographic_items
          ::GeographicArea.joins(:geographic_items)
        else
          ::GeographicArea.where.missing(:geographic_items)
        end
      end

      def and_clauses
        [ name_facet ]
      end

      def merge_clauses
        [
          containing_point_facet,
          geographic_items_facet,
       ]
      end

    end
  end
end
