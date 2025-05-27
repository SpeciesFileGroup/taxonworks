module Queries
  module Gazetteer

    class Filter < Query::Filter

      PARAMS = [
        :containing_point,
        :gazetteer_id,
        :name,
        gazetteer_id: [],
        name: []
      ].freeze

      # @return Array
      # @param name [String, Array]
      #   matches one or more named entities
      attr_accessor :name

      # @return Array
      # @param gazetteer_id [Integer, Array]
      attr_accessor :gazetteer_id

      # @param [String]
      #   WKT representation of a point.  All areas
      #     containing that point are returned
      #     e.g. `POINT(44 22)`
      attr_accessor :containing_point

      def initialize(query_params)
        super
        @name = params[:name]
        @containing_point = params[:containing_point]
      end

      def name
        [@name].flatten.compact
      end

      def gazetteer_id
        [@gazetteer_id].flatten.compact
      end

      def name_facet
        return nil if name.blank?
        table[:name].in(name)
      end

      def containing_point_facet
        return nil if containing_point.nil?

        ::Gazetteer
          .joins(:geographic_item)
          #.merge(::GeographicItem.polygons)
          .where(
            ::GeographicItem.st_covers_sql(
              ::GeographicItem.geography_as_geometry,
              ::GeographicItem.st_geom_from_text_sql(containing_point)
            )
          )
      end

      def and_clauses
        [ name_facet ]
      end

      def merge_clauses
        [
          containing_point_facet
        ]
      end

    end
  end
end
