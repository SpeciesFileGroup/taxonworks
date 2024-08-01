# A GeographicItem is one and only one of [point, line_string, polygon,
# multi_point, multi_line_string, multi_polygon, geometry_collection,
# geography] which describes a position, path, or area on the globe,
# generally associated with a geographic_area (through a
# geographic_area_geographic_item entry), a gazetteer, or a georeference.
#
# @!attribute geography
#   @return [RGeo::Geographic::Geography]
#   Holds a shape of any geographic type.
#
# @!attribute cached_total_area
#   @return [Numeric]
#     if polygon-based the value of the enclosed area in square meters
#
# Key methods in this giant library
#
# `#geo_object` - return a RGEO object representation
#
#
class GeographicItem < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::HasPapertrail
  include Shared::IsData
  include Shared::SharedAcrossProjects

  # @return [Boolean, RGeo object]
  # @params value [Hash in GeoJSON format] ?!
  # TODO: WHY! boolean not nil, or object
  # Used to build geographic items from a shape [ of what class ] !?
  attr_accessor :shape

  # @return [Boolean]
  #   When true cached values are not built
  attr_accessor :no_cached

  SHAPE_TYPES = [
    :point,
    :line_string,
    :polygon,
    :multi_point,
    :multi_line_string,
    :multi_polygon,
    :geometry_collection
  ].freeze

    # ANTI_MERIDIAN = '0X0102000020E61000000200000000000000008066400000000000405640000000000080664000000000004056C0'
    ANTI_MERIDIAN = 'LINESTRING (180 89.0, 180 -89.0)'.freeze

    has_many :cached_map_items, inverse_of: :geographic_item

    has_many :geographic_areas_geographic_items, dependent: :destroy, inverse_of: :geographic_item
    has_many :geographic_areas, through: :geographic_areas_geographic_items
    has_many :asserted_distributions, through: :geographic_areas
    has_many :geographic_area_types, through: :geographic_areas
    has_many :parent_geographic_areas, through: :geographic_areas, source: :parent

    has_many :georeferences, inverse_of: :geographic_item
    has_many :georeferences_through_error_geographic_item,
      class_name: 'Georeference', foreign_key: :error_geographic_item_id, inverse_of: :error_geographic_item
    has_many :collecting_events_through_georeferences, through: :georeferences, source: :collecting_event
    has_many :collecting_events_through_georeference_error_geographic_item,
      through: :georeferences_through_error_geographic_item, source: :collecting_event

    has_one :gazetteer, inverse_of: :geographic_item

    validate :some_data_is_provided
    validate :check_point_limits

    scope :include_collecting_event, -> { includes(:collecting_events_through_georeferences) }
    scope :geo_with_collecting_event, -> { joins(:collecting_events_through_georeferences) }
    scope :err_with_collecting_event, -> { joins(:georeferences_through_error_geographic_item) }

    after_save :set_cached, unless: Proc.new {|n| n.no_cached || errors.any? }
    after_save :align_winding

    class << self

      # DEPRECATED, moved to ::Queries::GeographicItem
      def st_union(geographic_item_scope)
        select('ST_Union(geography::geometry) as st_union')
          .where(id: geographic_item_scope.pluck(:id))
      end

      def st_covers_sql(shape1, shape2)
        Arel::Nodes::NamedFunction.new(
          'ST_Covers',
          [
            geometry_cast(shape1),
            geometry_cast(shape2)
          ]
        )
      end

      # True for those shapes that cover shape.
      def superset_of_sql(shape)
        st_covers_sql(
          geography_as_geometry,
          shape
        )
      end

      # @return [Scope] of items covering the union of geographic_item_ids;
      # does not include any of geographic_item_ids
      def superset_of_union_of(*geographic_item_ids)
        where(
          superset_of_sql(
            items_as_one_geometry_sql(*geographic_item_ids)
          )
        )
        .not_ids(*geographic_item_ids)
      end

      def st_covered_by_sql(shape1, shape2)
        Arel::Nodes::NamedFunction.new(
          'ST_CoveredBy',
          [
            self.geometry_cast(shape1),
            self.geometry_cast(shape2)
          ]
        )
      end

      # True for those shapes that are subsets of shape.
      def subset_of_sql(shape)
        st_covered_by_sql(
          geography_as_geometry,
          shape
        )
      end

      # Note: !! If the target GeographicItem#id crosses the anti-meridian then
      # you may/will get unexpected results.
      # TODO why don't we exclude self here?
      def subset_of_union_of_sql(*geographic_item_ids)
        subset_of_sql(
          items_as_one_geometry_sql(*geographic_item_ids)
        )
      end

      def st_distance_sql(shape1, shape2)
        Arel::Nodes::NamedFunction.new(
          'ST_Distance', [
            shape1,
            shape2
          ]
        )
      end

      def st_area_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_Area', [
            shape
          ]
        )
      end

      # Intended here to be used as an aggregate function
      def st_union_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_Union', [
            shape
          ]
        )
      end

      def st_dump_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_Dump', [
            shape
          ]
        )
      end

      def st_collect_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_Collect', [
            shape
          ]
        )
      end

      def st_is_valid_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_IsValid', [
            shape
          ]
        )
      end

      def st_is_valid_reason_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_IsValidReason', [
            shape
          ]
        )
      end

      def st_as_text_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_AsText', [
            shape
          ]
        )
      end

      def st_geometry_type(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_GeometryType', [
            geometry_cast(shape)
          ]
        )
      end

      def st_minimum_bounding_radius_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_MinimumBoundingRadius', [
            shape
          ]
        )
      end

      def st_as_geo_json_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_AsGeoJSON', [
            shape
          ]
        )
      end

      def st_geography_from_text_sql(wkt)
        wkt = ActiveRecord::Base.connection.quote_string(wkt)
        Arel::Nodes::NamedFunction.new(
          'ST_GeographyFromText', [
            Arel::Nodes::Quoted.new(wkt),
          ]
        )
      end

      def st_geog_from_text_sql(wkt)
        st_geography_from_text_sql(wkt)
      end

      def st_geom_from_text_sql(wkt)
        wkt = ActiveRecord::Base.connection.quote_string(wkt)
        Arel::Nodes::NamedFunction.new(
          'ST_GeometryFromText', [
            Arel::Nodes::Quoted.new(wkt),
            Arel::Nodes::Quoted.new(4326)
          ]
        )
      end

      def st_centroid_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_Centroid', [
            shape
          ]
        )
      end

      def st_buffer_sql(shape, distance, num_seg_quarter_circle: 8)
        Arel::Nodes::NamedFunction.new(
          'ST_Buffer', [
            self.geography_cast(shape),
            Arel::Nodes::Quoted.new(distance),
            Arel::Nodes::Quoted.new(num_seg_quarter_circle)
          ]
        )
      end

      def st_intersects_sql(shape1, shape2)
        Arel::Nodes::NamedFunction.new(
          'ST_Intersects', [
            # anti-meridian checks can fail if these are converted to geometry
            shape1,
            shape2
          ]
        )
      end

      def st_shift_longitude_sql(shape)
        Arel::Nodes::NamedFunction.new(
          'ST_ShiftLongitude', [
            geometry_cast(shape)
          ]
        )
      end

      # True for those shapes that are within `distance` of (i.e. intersect the
      # `distance`-buffer of) shape. This is a geography dwithin, distance is in
      # meters.
      def st_dwithin_sql(shape1, shape2, distance)
        Arel::Nodes::NamedFunction.new(
          'ST_DWithin', [
            shape1,
            shape2,
            Arel::Nodes::Quoted.new(distance)
          ]
        )
      end

      # @param [String] wkt
      # @return [Boolean]
      #   whether or not the wkt intersects with the anti-meridian
      # TODO is this spec'd?
      def crosses_anti_meridian?(wkt)
        # TODO make this a quote_string method on gi?
        wkt = ActiveRecord::Base.connection.quote_string(wkt)
        select_one(
          st_intersects_sql(
            st_geography_from_text_sql(wkt),
            st_geography_from_text_sql(ANTI_MERIDIAN)
          )
        )['st_intersects']
      end

      # Unused, kept for reference
      # @param [Integer] ids
      # @return [Boolean]
      #   whether or not any GeographicItem passed intersects the anti-meridian
      #   !! StrongParams security considerations This is our first line of
      #   defense against queries that define multiple shapes, one or more of
      #   which crosses the anti-meridian.  In this case the current TW strategy
      #   within the UI is to abandon the search, and prompt the user to
      #   refactor the query.
      def crosses_anti_meridian_by_id?(*ids)
        q = "SELECT ST_Intersects((SELECT single_geometry FROM (#{GeographicItem.single_geometry_sql(*ids)}) as " \
              'left_intersect), ST_GeogFromText(?)) as r;', ANTI_MERIDIAN
        GeographicItem.find_by_sql(q).first.r
      end

      #
      # SQL fragments
      #

      # @param [Integer, String]
      # @return [SelectManager]
      #   a SQL select statement that returns the *geometry* for the
      #   geographic_item with the specified id
      def select_geometry_sql(geographic_item_id)
        arel_table
          .project(geography_as_geometry)
          .where(arel_table[:id].eq(geographic_item_id))
      end

      # @param [Integer, String]
      # @return [SelectManager]
      #   a SQL select statement that returns the geography for the
      #   geographic_item with the specified id
      def select_geography_sql(geographic_item_id)
        #select(GeographicItem::GEOGRAPHY_SQL).where(id: geographic_item_id)
        arel_table
          .project(arel_table[:geography])
          .where(arel_table[:id].eq(geographic_item_id))
      end

      # @param [Symbol] choice, either :latitude or :longitude
      # @return [String]
      #   a fragment returning either latitude or longitude columns
      def lat_long_sql(choice)
        return nil unless [:latitude, :longitude].include?(choice)
        f = "'D.DDDDDD'" # TODO: probably a constant somewhere
        v = (choice == :latitude ? 1 : 2)

        'split_part(ST_AsLatLonText(' \
          "ST_Centroid(geography::geometry), #{f}), ' ', #{v}) AS #{choice}"
      end

      # @param [Integer] geographic_item_id
      # @param [Integer] radius in meters
      # @return [Scope] of shapes within distance of (i.e. whose
      #   distance-buffer intersects) geographic_item_id
      def within_radius_of_item_sql(geographic_item_id, radius)
        st_dwithin_sql(
          select_geography_sql(geographic_item_id),
          arel_table[:geography],
          radius
        )
      end

      def within_radius_of_item(geographic_item_id, radius)
        where(within_radius_of_item_sql(geographic_item_id, radius))
      end

      # @param [Integer] geographic_item_id
      # @param [Number] distance (in meters) (positive only?!)
      # @param [Number] buffer: distance in meters to grow/shrink the shapes
      #   checked against (negative allowed)
      # @return [NamedFunction] Shapes whose `buffer` is within `distance` of
      #   geographic_item
      def st_buffer_st_within_sql(geographic_item_id, distance, buffer = 0)
        # You can't always switch the buffer to the second argument, even when
        # distance is 0, without further assumptions (think of buffer being
        # large negative compared to geographic_item_id, but not another shape))
        st_dwithin_sql(
          st_buffer_sql(
            arel_table[:geography],
            buffer
          ),
          select_geography_sql(geographic_item_id),
          distance
        )
      end

      # TODO: 3D is overkill here
      # @param [String] wkt
      # @param [Integer] distance (meters)
      # @return [NamedFunction] Shapes within distance of (i.e. whose
      #   distance-buffer intersects) wkt
      def intersecting_radius_of_wkt_sql(wkt, distance)
        wkt = ActiveRecord::Base.connection.quote_string(wkt) # sanitize
        st_dwithin_sql(
          st_geography_from_text_sql(wkt),
          arel_table[:geography],
          distance
        )
      end

      # @param [String] wkt
      # @param [Integer] distance (meters)
      # @return [NamedFunction] Those items within the distance-buffer of wkt
      # TODO make me understand how this is different than the previous fcn
      def within_radius_of_wkt_sql(wkt, distance)
        wkt = ActiveRecord::Base.connection.quote_string(wkt) # sanitize
        subset_of_sql(
          st_buffer_sql(
            st_geography_from_text_sql(wkt),
            distance
          )
        )
      end

      # @param [Integer, Array of Integer] geographic_item_ids
      # @return [String]
      #    returns one or more geographic items combined as a single geometry
      #    in a column 'single_geometry'
      def single_geometry_sql(*geographic_item_ids)
        geographic_item_ids.flatten!

        Arel.sql(
          "SELECT ST_Collect(f.the_geom) AS single_geometry
           FROM (
             SELECT (
               ST_DUMP(geography::geometry)
             ).geom AS the_geom
             FROM geographic_items
             WHERE id in (#{geographic_item_ids.join(',')})
           ) AS f"
        )
      end

      # @param [Integer, Array of Integer] geographic_item_ids
      # @return [SelectManager]
      #   returns a single geometry "column" (paren wrapped) as
      #   "single_geometry" for multiple geographic item ids, or the geometry
      #   as 'geometry' for a single id
      # TODO make sure this is spec'd for both cases
      def items_as_one_geometry_sql(*geographic_item_ids)
        geographic_item_ids.flatten! # *ALWAYS* reduce the pile to a single level of ids
        if geographic_item_ids.count == 1
          geometry_for_sql(geographic_item_ids.first)
        else
          single_geometry_sql(geographic_item_ids)
        end
      end

      # @params [String] well known text
      # @return [NamedFunction] the SQL fragment for those geometric shapes
      # covered by wkt
      # Note: this routine is called when it is already known that the A
      # argument crosses anti-meridian
      def covered_by_wkt_shifted_sql(wkt)
        wkt = ActiveRecord::Base.connection.quote_string(wkt) # sanitize
        st_covered_by_sql(
          st_shift_longitude_sql(geography_as_geometry),
          st_shift_longitude_sql(st_geom_from_text_sql(wkt))
        )
      end

      # @params [String] wkt
      # @return [NamedFunction] SQL fragment limiting geographic items to those
      # covered by this WKT
      def covered_by_wkt_sql(wkt)
        wkt = ActiveRecord::Base.connection.quote_string(wkt) # sanitize
        if crosses_anti_meridian?(wkt)
          # TODO Add anti-meridian test here
          covered_by_wkt_shifted_sql(wkt)
        else
          subset_of_sql(
            st_geom_from_text_sql(wkt)
          )
        end
      end

      # @param [Integer] geographic_item_id
      # @return [SelectManager] selects the shape column as geometry for the
      # given geographic_item_id
      def geometry_for_sql(geographic_item_id)
        #select(GEOMETRY_SQL)
        #.where(id: geographic_item_id)
        arel_table
          .project(geography_as_geometry)
          .where(arel_table[:id].eq(geographic_item_id))
      end

      #
      # Scopes
      #

      # return [Scope]
      #   A scope that limits the result to those GeographicItems that have a collecting event
      #   through either the geographic_item or the error_geographic_item
      #
      # A raw SQL join approach for comparison
      #
      # GeographicItem.joins('LEFT JOIN georeferences g1 ON geographic_items.id = g1.geographic_item_id').
      #   joins('LEFT JOIN georeferences g2 ON geographic_items.id = g2.error_geographic_item_id').
      #   where("(g1.geographic_item_id IS NOT NULL OR g2.error_geographic_item_id IS NOT NULL)").uniq

      # @return [Scope] GeographicItem
      # This uses an Arel table approach, this is ultimately more decomposable if we need. Of use:
      #  http://danshultz.github.io/talks/mastering_activerecord_arel  <- best
      #  https://github.com/rails/arel
      #  http://stackoverflow.com/questions/4500629/use-arel-for-a-nested-set-join-query-and-convert-to-activerecordrelation
      #  http://rdoc.info/github/rails/arel/Arel/SelectManager
      #  http://stackoverflow.com/questions/7976358/activerecord-arel-or-condition
      #
      def with_collecting_event_through_georeferences
        geographic_items = GeographicItem.arel_table
        georeferences = Georeference.arel_table
        g1 = georeferences.alias('a')
        g2 = georeferences.alias('b')

        c = geographic_items.join(g1, Arel::Nodes::OuterJoin).on(geographic_items[:id].eq(g1[:geographic_item_id]))
          .join(g2, Arel::Nodes::OuterJoin).on(geographic_items[:id].eq(g2[:error_geographic_item_id]))

        GeographicItem.joins(# turn the Arel back into scope
                             c.join_sources # translate the Arel join to a join hash(?)
                            ).where(
                              g1[:id].not_eq(nil).or(g2[:id].not_eq(nil)) # returns a Arel::Nodes::Grouping
                            ).distinct
      end

      # This is a geographic intersect, not geometric
      def intersecting(shape, *geographic_item_ids)
        shape = shape.to_s.downcase
        if shape == 'any'
          pieces = []
          SHAPE_TYPES.each { |shape|
            pieces.push(
              self.intersecting(shape, geographic_item_ids).to_a
            )
          }

          # @TODO change 'id in (?)' to some other sql construct
          GeographicItem.where(id: pieces.flatten.map(&:id))
        else
          a = geographic_item_ids.flatten.collect { |geographic_item_id|
            # seems like we want this: http://danshultz.github.io/talks/mastering_activerecord_arel/#/15/2
            st_intersects_sql(
              shape_column_sql(shape),
              select_geography_sql(geographic_item_id)
            )
          }

          q = a.first
          if a.count > 1
            a[1..].each { |i| q = q.or(i) }
          end

          where(q)
        end
      end

      # rubocop:disable Metrics/MethodLength
      # @param [String] shape can be any of SHAPE_TYPES, or 'any' to check
      # against all types, 'any_poly' to check against 'polygon' or
      # 'multi_polygon', or 'any_line' to check against 'line_string' or
      # 'multi_line_string'.
      # @param [GeographicItem] geographic_items or array of geographic_items
      #                         to be tested.
      # @return [Scope] of GeographicItems whose `shape` contains at least one
      #                 of geographic_items.
      #                 !! Returns geographic_item when geographic_item is of
      #                    type `shape`
      #
      # If this scope is given an Array of GeographicItems as a second parameter,
      # it will return the 'OR' of each of the objects against the table.
      # SELECT COUNT(*) FROM "geographic_items"
      #        WHERE (ST_Covers(polygon::geometry, GeomFromEWKT('srid=4326;POINT (0.0 0.0 0.0)'))
      #               OR ST_Covers(polygon::geometry, GeomFromEWKT('srid=4326;POINT (-9.8 5.0 0.0)')))
      #
      def st_covers(shape, *geographic_items)
        # TODO areal return if none
        geographic_items.flatten! # in case there is a array of arrays, or multiple objects
        shape = shape.to_s.downcase
        case shape
        when 'any'
          part = []
          SHAPE_TYPES.each { |s|
            part.push(st_covers(s, geographic_items).to_a)
          }
          # TODO: change 'id in (?)' to some other sql construct
          where(id: part.flatten.map(&:id))

        when 'any_poly', 'any_line'
          part = []
          SHAPE_TYPES.each { |s|
            s = s.to_s
            if s.index(shape.gsub('any_', ''))
              part.push(st_covers(s, geographic_items).to_a)
            end
          }
          # TODO: change 'id in (?)' to some other sql construct
          where(id: part.flatten.map(&:id))

        else
          a = geographic_items.flatten.collect { |geographic_item|
            st_covers_sql(
              shape_column_sql(shape),
              select_geometry_sql(geographic_item.id)
            )
          }

          q = a.first
          if a.count > 1
            a[1..].each { |i| q = q.or(i) }
          end

          # This will prevent the invocation of *ALL* of the GeographicItems
          # if there are no GeographicItems in the request (see
          # CollectingEvent.name_hash(types)).
          q = 'FALSE' if q.blank?
          where(q) # .not_including(geographic_items)
        end
      end

      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      # @param shape [String] can be any of SHAPE_TYPES, or 'any' to check
      # against all types, 'any_poly' to check against 'polygon' or
      # 'multi_polygon', or 'any_line' to check against 'line_string' or
      # 'multi_line_string'.
      # @param geographic_items [GeographicItem] Can be a single
      # GeographicItem, or an array of GeographicItem.
      # @return [Scope] of all GeographicItems of the given `shape` covered by
      # one or more of geographic_items
      # !! Returns geographic_item when geographic_item is of type `shape`
      def st_covered_by(shape, *geographic_items)
        # TODO return if none
        shape = shape.to_s.downcase
        case shape
        when 'any'
          part = []
          SHAPE_TYPES.each { |s|
            part.push(GeographicItem.st_covered_by(s, geographic_items).to_a)
          }
          # @TODO change 'id in (?)' to some other sql construct
          GeographicItem.where(id: part.flatten.map(&:id))

        when 'any_poly', 'any_line'
          part = []
          SHAPE_TYPES.each { |s|
            s = s.to_s
            if s.index(shape.gsub('any_', ''))
              part.push(GeographicItem.st_covered_by(s, geographic_items).to_a)
            end
          }
          # @TODO change 'id in (?)' to some other sql construct
          GeographicItem.where(id: part.flatten.map(&:id))

        else
          a = geographic_items.flatten.collect { |geographic_item|
            st_covered_by_sql(
              shape_column_sql(shape),
              select_geometry_sql(geographic_item.id)
            )
          }

          q = a.first
          if a.count > 1
            a[1..].each { |i| q = q.or(i) }
          end

          q = 'FALSE' if q.blank?
          where(q) # .not_including(geographic_items)
        end
      end

      # @param [RGeo::Point] center in lat/long
      # @param [Integer] radius of the circle, in meters
      # @param [Integer] buffer_resolution: the number of sides of the polygon
      #                  approximation per quarter circle
      # @return [RGeo::Polygon] A polygon approximation of the desired circle, in
      #                         geographic coordinates
      def circle(center, radius, buffer_resolution: 8)
        # TODO check params

        circle_wkb = select_one(
          st_buffer_sql(
            st_geography_from_text_sql(
              "POINT (#{center.x} #{center.y})",
            ),
            radius,
            num_seg_quarter_circle: buffer_resolution
          )
        )['st_buffer']

        Gis::FACTORY.parse_wkb(circle_wkb)
      end

      # rubocop:enable Metrics/MethodLength

      # @param [GeographicItem]
      # @return [Scope]
      def not_including(geographic_items)
        where.not(id: geographic_items)
      end

      #
      # Other
      #

      # @param [RGeo::Point] point
      # @return [Hash]
      #   as per #inferred_geographic_name_hierarchy but for Rgeo point
      def point_inferred_geographic_name_hierarchy(point)
        self
          .where(superset_of_sql(st_geom_from_text_sql(point.to_s)))
          .order(cached_total_area: :ASC)
          .first&.inferred_geographic_name_hierarchy
      end
    end # class << self

    # @return [Hash]
    #    a geographic_name_classification or empty Hash
    # This is a quick approach that works only when
    # the geographic_item is linked explicitly to a GeographicArea.
    #
    # !! Note that it is not impossible for a GeographicItem to be linked
    # to > 1 GeographicArea, in that case we are assuming that all are
    # equally refined, this might not be the case in the future because
    # of how the GeographicArea gazetteer is indexed.
    def quick_geographic_name_hierarchy
      geographic_areas.order(:id).each do |ga|
        h = ga.geographic_name_classification # not quick enough !!
        return h if h.present?
      end
      return {}
    end

    # @return [Hash]
    #   a geographic_name_classification (see GeographicArea) inferred by
    # finding the smallest area covering this GeographicItem, in the most accurate gazetteer
    # and using it to return country/state/county. See also the logic in
    # filling in missing levels in GeographicArea.
    def inferred_geographic_name_hierarchy
      if small_area = covering_geographic_areas
        .joins(:geographic_areas_geographic_items)
        .merge(GeographicAreasGeographicItem.ordered_by_data_origin)
        .ordered_by_area
        .first

        small_area.geographic_name_classification
      else
        {}
      end
    end

    def geographic_name_hierarchy
      a = quick_geographic_name_hierarchy # quick; almost never the case, UI not setup to do this
      return a if a.present?
      inferred_geographic_name_hierarchy # slow
    end

    # @return [Scope]
    #   the Geographic Areas that cover (gis) this geographic item
    def covering_geographic_areas
      GeographicArea
      .joins(:geographic_items)
      .includes(:geographic_area_type)
      .joins(
        "JOIN (#{GeographicItem.superset_of_union_of(id).to_sql}) AS j ON " \
        'geographic_items.id = j.id'
      )
    end

    # @param [GeographicItem] geographic_item
    # @return [Double] distance in meters
    # Works with changed and non persisted objects
    def st_distance_to_geographic_item(geographic_item)
      if persisted? && !changed?
        a = self.class.select_geography_sql(id)
      else
        a = self.class.st_geography_from_text_sql(geo_object.to_s)
      end

      if geographic_item.persisted? && !geographic_item.changed?
        b = self.class.select_geography_sql(geographic_item.id)
      else
        b = self.class.st_geography_from_text_sql(geographic_item.geo_object.to_s)
      end

      self.class.select_one(
        self.class.st_distance_sql(a, b)
      )['st_distance']
    end

    # @return [String]
    #   a WKT POINT representing the geometry centroid of the geographic item
    def st_centroid
      GeographicItem
        .where(id:)
        .pick(
          self.class.st_as_text_sql(
            self.class.st_centroid_sql(self.class.geography_as_geometry)
          )
        )
    end

    # @return [RGeo::Geographic::ProjectedPointImpl]
    #    representing the geometric centroid of this geographic item
    def centroid
      return geo_object if geo_object_type == :point

      Gis::FACTORY.parse_wkt(st_centroid)
    end

    # @return [Array]
    #   the lat, long, as STRINGs for the geometric centroid of this geographic
    #   item
    #   Meh- this: https://postgis.net/docs/en/ST_MinimumBoundingRadius.html
    def center_coords
      r = GeographicItem.find_by_sql(
        'Select split_part(ST_AsLatLonText(ST_Centroid(geography::geometry), ' \
        "'D.DDDDDD'), ' ', 1) latitude, split_part(ST_AsLatLonText(ST_Centroid" \
        "(geography::geometry), 'D.DDDDDD'), ' ', 2) " \
        "longitude from geographic_items where id = #{id};")[0]

      [r.latitude, r.longitude]
    end

    # !!TODO: migrate these to use native column calls

    # @param [geo_object]
    # @return [Boolean]
    def contains?(target_geo_object)
      return nil if target_geo_object.nil?
      self.geo_object.contains?(target_geo_object)
    end

    # @param [geo_object]
    # @return [Boolean]
    def within?(target_geo_object)
      self.geo_object.within?(target_geo_object)
    end

    # @param [geo_object]
    # @return [Boolean]
    def intersects?(target_geo_object)
      self.geo_object.intersects?(target_geo_object)
    end

    # @return [Hash] in GeoJSON format
    def to_geo_json
      JSON.parse(
        self.class.select_one(
          self.class.st_as_geo_json_sql(self.class.select_geography_sql(id))
        )['st_asgeojson']
      )
    end

    # @return [Hash]
    #   the shape as a GeoJSON Feature with some item metadata
    def to_geo_json_feature
      {'type' => 'Feature',
       'geometry' => to_geo_json,
       'properties' => {
         'geographic_item' => {
           'id' => id}
       }
      }
    end

    # @param value [String] geojson like:
    #   '{"type":"Feature","geometry":{"type":"Point","coordinates":[2.5,4.0]},"properties":{"color":"red"}}'
    #
    #   '{"type":"Feature","geometry":{"type":"Polygon","coordinates":"[[[-125.29394388198853, 48.584480409793],
    #      [-67.11035013198853, 45.09937589848195],[-80.64550638198853, 25.01924647619111],[-117.55956888198853,
    #      32.5591595028449],[-125.29394388198853, 48.584480409793]]]"},"properties":{}}'
    #
    #  '{"type":"Point","coordinates":[2.5,4.0]},"properties":{"color":"red"}}'
    #
    def shape=(value)
      return if value.blank?

      begin
        geom = RGeo::GeoJSON.decode(value, json_parser: :json, geo_factory: Gis::FACTORY)
      rescue RGeo::Error::InvalidGeometry => e
        errors.add(:base, "invalid geometry: #{e}")
        return
      end

      object = nil

      s = geom.respond_to?(:geometry) ? geom.geometry.to_s : geom.to_s

      begin
        object = Gis::FACTORY.parse_wkt(s)
      rescue RGeo::Error::InvalidGeometry
        errors.add(:self, 'Shape value is an Invalid Geometry')
        return
      end

      write_attribute(:geography, object)
    end

    # @return [String] wkt
    def to_wkt
      #  10k  #<Benchmark::Tms:0x00007fb0dfd30fd0 @label="", @real=25.237487000005785, @cstime=0.0, @cutime=0.0, @stime=1.1704609999999995, @utime=5.507929999999988, @total=6.678390999999987>
      #  GeographicItem.select("ST_AsText( #{GeographicItem::GEOMETRY_SQL.to_sql}) wkt").where(id: id).first.wkt

      # 10k <Benchmark::Tms:0x00007fb0e02f7540 @label="", @real=21.619827999995323, @cstime=0.0, @cutime=0.0, @stime=0.8850890000000007, @utime=3.2958549999999605, @total=4.180943999999961>
      select_from_self(
        self.class.st_as_text_sql(self.class.geography_as_geometry)
      )['st_astext']
    end

    # @return [Float] in meters, calculated
    # TODO: share with world
    #    Geographic item 96862 (Cajamar in Brazil) is the only(?) record to fail using `false` (quicker) method of everything we tested
    def area
      select_from_self(
        self.class.st_area_sql(self.class.arel_table[:geography])
      )['st_area']
    end

    # TODO: This is bad, while internal use of ONE_WEST_MEAN is consistent it is in-accurate given the vast differences of radius vs. lat/long position.
    # When we strike the error-polygon from radius we should remove this
    #
    # Use case is returning the radius from a circle we calculated via buffer for error-polygon creation.
    def radius
      r = select_from_self(
        self.class.st_minimum_bounding_radius_sql(
          self.class.geography_as_geometry
        )
      )['st_minimumboundingradius'].split(',').last.chop.to_f

      (r * Utilities::Geo::ONE_WEST_MEAN).to_i
    end

    # Convention is to store in PostGIS in CCW
    # @return Array [Boolean]
    #   false - cw
    #   true - ccw (preferred), except see donuts
    def orientations
      if geography_is_multi_polygon?
        ApplicationRecord.connection.execute(
             "SELECT ST_IsPolygonCCW(a.geom) as is_ccw
                FROM ( SELECT b.id, (ST_Dump(p_geom)).geom AS geom
                   FROM (SELECT id, geography::geometry AS p_geom FROM geographic_items where id = #{id}) AS b
              ) AS a;").collect{|a| a['is_ccw']}
      elsif geography_is_polygon?
        ApplicationRecord.connection.execute(
          "SELECT ST_IsPolygonCCW(geography::geometry) as is_ccw \
          FROM geographic_items where  id = #{id};"
        ).collect { |a| a['is_ccw'] }
      else
        []
      end
    end

    # @return Boolean
    #   looks at all orientations
    #   if they follow the pattern [true, false, ... <all false>] then `true`, else `false`
    # !! Does not confirm that shapes are nested !!
    def is_basic_donut?
      a = orientations
      b = a.shift
      return false unless b
      a.uniq!
      a == [false]
    end

    def st_is_valid
      select_from_self(
        self.class.st_is_valid_sql(
          self.class.geography_as_geometry
        )
      )['st_isvalid']
    end

    def st_is_valid_reason
      select_from_self(
        self.class.st_is_valid_reason_sql(
          self.class.geography_as_geometry
        )
      )['st_isvalidreason']
    end

    # @return [Symbol]
    #   the specific type of geography: :point, :multipolygon, etc.
    def geo_object_type
      return geography.geometry_type.type_name.underscore.to_sym if
        geography

      nil
    end

    # @return [RGeo instance, nil]
    #  the Rgeo shape (See http://rubydoc.info/github/dazuma/rgeo/RGeo/Feature)
    def geo_object
      geography
    end

    private

    def geography_is_polygon?
      geo_object_type == :polygon
    end

    def geography_is_multi_polygon?
      geo_object_type == :multi_polygon
    end

    # @param [String] shape, the name of the shape you want, e.g. 'polygon'
    # @return [Arel::Nodes::Case]
    #   A Case statement that selects the geography column if that column is of
    #   type `shape`, otherwise NULL
    def self.shape_column_sql(shape)
      st_shape = 'ST_' + shape.to_s.camelize

      Arel::Nodes::Case.new(st_geometry_type(arel_table[:geography]))
        .when(st_shape.to_sym).then(arel_table[:geography])
        .else(Arel.sql('NULL'))
    end

    def select_from_self(named_function)
      # This is faster than GeographicItem.select(...)
      ActiveRecord::Base.connection.execute(
        self.class.arel_table
        .project(named_function)
        .where(self.class.arel_table[:id].eq(id))
        .to_sql
      ).to_a.first
    end

    def self.select_one(named_function)
      # This is faster than select(...)
      ActiveRecord::Base.connection.execute(
        'SELECT ' +
        named_function.to_sql
      )
      .to_a.first
    end

    def align_winding
      if orientations.flatten.include?(false)
        if (geography_is_polygon? || geography_is_multi_polygon?)
          ApplicationRecord.connection.execute(
            "UPDATE geographic_items SET geography = ST_ForcePolygonCCW(geography::geometry)
              WHERE id = #{self.id};"
           )
        end
      end
    end

    # Crude debuging helper, write the shapes
    # to a png
    def self.debug_draw(geographic_item_ids = [])
      return false if geographic_item_ids.empty?
      sql = "SELECT ST_AsPNG(
         ST_AsRaster(
            (SELECT ST_Union(geography::geometry) from geographic_items where id IN (" + geographic_item_ids.join(',') + ")), 1920, 1080
        )
       ) png;"

      # ST_Buffer( multi_polygon::geometry, 0, 'join=bevel'),
      #     1920,
      #     1080)


      result = ActiveRecord::Base.connection.execute(sql).first['png']
      r = ActiveRecord::Base.connection.unescape_bytea(result)

      prefix = if geographic_item_ids.size > 10
                 'multiple'
               else
                 geographic_item_ids.join('_')
               end

      n = prefix + '_debug.draw.png'

      # Open the file in binary write mode ("wb")
      File.open(n, 'wb') do |file|
        # Write the binary data to the file
        file.write(r)
      end
    end

    # def png

    #   if ids = Otu.joins(:cached_map_items).first.cached_map_items.pluck(:geographic_item_id)

    #     sql = "SELECT ST_AsPNG(
    #    ST_AsRaster(
    #        ST_Buffer( multi_polygon::geometry, 0, 'join=bevel'),
    #            1024,
    #            768)
    #     ) png
    #        from geographic_items where id IN (" + ids.join(',') + ');'

    #     # hack, not the best way to unpack result
    #     result = ActiveRecord::Base.connection.execute(sql).first['png']
    #     r = ActiveRecord::Base.connection.unescape_bytea(result)

    #     send_data r, filename: 'foo.png', type: 'imnage/png'

    #   else
    #     render json: {foo: false}
    #   end
    # end

    def set_cached
      update_column(:cached_total_area, area)
    end

    def some_data_is_provided
      errors.add(:base, 'No shape provided or provided shape is invalid') if
        geography.nil?
    end

    # @return [Boolean]
    # true iff point.x is between -180.0 and +180.0
    def check_point_limits
      if geo_object_type == :point
        errors.add(:point_limit, 'Longitude exceeds limits: 180.0 to -180.0.') if
          geography.x > 180.0 || geography.x < -180.0
      end
    end

    # TODO what is sql?
    def self.geography_cast(sql)
      # Arel::Nodes::NamedFunction.new('CAST', [sql.as('geography')])
      Arel.sql(
        Arel::Nodes::Grouping.new(sql).to_sql + '::geography'
      )
    end

    # TODO what is sql?
    def self.geometry_cast(sql)
      # specs fail using:
      # Arel::Nodes::NamedFunction.new('CAST', [sql.as('geometry')])
      Arel.sql(
        Arel::Nodes::Grouping.new(sql).to_sql + '::geometry'
      )
    end

    def self.geography_as_geometry
      Arel.sql('geography::geometry')
    end
end
