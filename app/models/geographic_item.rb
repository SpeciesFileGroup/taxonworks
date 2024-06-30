# require 'rgeo'

# A GeographicItem is one and only one of [point, line_string, polygon, multi_point, multi_line_string,
# multi_polygon, geometry_collection, geography] which describes a position, path, or area on the globe, generally associated
# with a geographic_area (through a geographic_area_geographic_item entry), a gazetteer, or a georeference.
#
# @!attribute point
#   @return [RGeo::Geographic::ProjectedPointImpl]
#
# @!attribute line_string
#   @return [RGeo::Geographic::ProjectedLineStringImpl]
#
# @!attribute polygon
#   @return [RGeo::Geographic::ProjectedPolygonImpl]
#   CCW orientation is applied
#
# @!attribute multi_point
#   @return [RGeo::Geographic::ProjectedMultiPointImpl]
#
# @!attribute multi_line_string
#   @return [RGeo::Geographic::ProjectedMultiLineStringImpl]
#
# @!attribute multi_polygon
#   @return [RGeo::Geographic::ProjectedMultiPolygonImpl]
#   CCW orientation is applied
#
# @!attribute geometry_collection
#   @return [RGeo::Geographic::ProjectedGeometryCollectionImpl]
#
# @!attribute geography
#   @return [RGeo::Geographic::Geography]
#   Holds a shape of any geographic type. Currently only used by Gazetteer,
#   eventually all of the above shapes will be folded into here.
#
# @!attribute type
#   @return [String]
#     Rails STI
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

  # Methods that are deprecated or used only in specs
  # TODO move spec-only methods somewhere else?
  include GeographicItem::Deprecated

  # @return [Hash, nil]
  #   An internal variable for use in super calls, holds a Hash in GeoJSON format (temporarily)
  attr_accessor :geometry

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

  DATA_TYPES = (SHAPE_TYPES + [:geography]).freeze

  GEOMETRY_SQL = Arel::Nodes::Case.new(arel_table[:type])
    .when('GeographicItem::MultiPolygon').then(Arel::Nodes::NamedFunction.new('CAST', [arel_table[:multi_polygon].as('geometry')]))
    .when('GeographicItem::Point').then(Arel::Nodes::NamedFunction.new('CAST', [arel_table[:point].as('geometry')]))
    .when('GeographicItem::LineString').then(Arel::Nodes::NamedFunction.new('CAST', [arel_table[:line_string].as('geometry')]))
    .when('GeographicItem::Polygon').then(Arel::Nodes::NamedFunction.new('CAST', [arel_table[:polygon].as('geometry')]))
    .when('GeographicItem::MultiLineString').then(Arel::Nodes::NamedFunction.new('CAST', [arel_table[:multi_line_string].as('geometry')]))
    .when('GeographicItem::MultiPoint').then(Arel::Nodes::NamedFunction.new('CAST', [arel_table[:multi_point].as('geometry')]))
    .when('GeographicItem::GeometryCollection').then(Arel::Nodes::NamedFunction.new('CAST', [arel_table[:geometry_collection].as('geometry')]))
    .when('GeographicItem::Geography').then(Arel::Nodes::NamedFunction.new('CAST', [arel_table[:geography].as('geometry')]))
    .freeze

  GEOGRAPHY_SQL = "CASE geographic_items.type
    WHEN 'GeographicItem::MultiPolygon' THEN multi_polygon
    WHEN 'GeographicItem::Point' THEN point
    WHEN 'GeographicItem::LineString' THEN line_string
    WHEN 'GeographicItem::Polygon' THEN polygon
    WHEN 'GeographicItem::MultiLineString' THEN multi_line_string
    WHEN 'GeographicItem::MultiPoint' THEN multi_point
    WHEN 'GeographicItem::GeometryCollection' THEN geometry_collection
    WHEN 'GeographicItem::Geography' THEN geography
    END".freeze

    # ANTI_MERIDIAN = '0X0102000020E61000000200000000000000008066400000000000405640000000000080664000000000004056C0'
    ANTI_MERIDIAN = 'LINESTRING (180 89.0, 180 -89)'.freeze

    has_many :cached_map_items, inverse_of: :geographic_item

    has_many :geographic_areas_geographic_items, dependent: :destroy, inverse_of: :geographic_item
    has_many :geographic_areas, through: :geographic_areas_geographic_items
    has_many :asserted_distributions, through: :geographic_areas
    has_many :geographic_area_types, through: :geographic_areas
    has_many :parent_geographic_areas, through: :geographic_areas, source: :parent

    has_many :gazetteers, inverse_of: :geographic_item
    has_many :georeferences, inverse_of: :geographic_item
    has_many :georeferences_through_error_geographic_item,
      class_name: 'Georeference', foreign_key: :error_geographic_item_id, inverse_of: :error_geographic_item
    has_many :collecting_events_through_georeferences, through: :georeferences, source: :collecting_event
    has_many :collecting_events_through_georeference_error_geographic_item,
      through: :georeferences_through_error_geographic_item, source: :collecting_event

    # TODO: THIS IS NOT GOOD
    before_validation :set_type_if_shape_column_present

    validate :some_data_is_provided
    validates :type, presence: true # not needed

    scope :include_collecting_event, -> { includes(:collecting_events_through_georeferences) }
    scope :geo_with_collecting_event, -> { joins(:collecting_events_through_georeferences) }
    scope :err_with_collecting_event, -> { joins(:georeferences_through_error_geographic_item) }

    after_save :set_cached, unless: Proc.new {|n| n.no_cached || errors.any? }
    after_save :align_winding

    class << self

      def st_union(geographic_item_scope)
        self.select("ST_Union(#{GeographicItem::GEOMETRY_SQL.to_sql}) as collection")
          .where(id: geographic_item_scope.pluck(:id))
      end

      # True for those shapes that are within (subsets of) the shape_sql shape.
      def within_sql(shape_sql)
        'ST_Covers(' \
          "#{shape_sql}, " \
          "#{GeographicItem::GEOMETRY_SQL.to_sql}" \
        ')'
      end

      # Note: !! If the target GeographicItem#id crosses the anti-meridian then
      # you may/will get unexpected results.
      def within_union_of_sql(*geographic_item_ids)
        within_sql("#{
          self.items_as_one_geometry_sql(*geographic_item_ids)
        }")
      end

      def within_union_of(*geographic_item_ids)
        where(within_union_of_sql(*geographic_item_ids))
      end

      # True for those shapes that cover the shape_sql shape.
      def covering_sql(shape_sql)
        'ST_Covers(' \
          "#{GeographicItem::GEOMETRY_SQL.to_sql}, " \
          "#{shape_sql}" \
        ')'
      end

      # @return [Scope] of items covering the union of geographic_item_ids;
      # does not include any of geographic_item_ids
      def covering_union_of(*geographic_item_ids)
        where(
          self.covering_sql(
            self.items_as_one_geometry_sql(*geographic_item_ids)
          )
        )
        .not_ids(*geographic_item_ids)
      end

      # @param [Integer] geographic_item_id
      # @param [Integer] buffer can be positive or negative, in meters for the
      #                  default geographic case
      # @param [Boolean] geometric: whether the buffer should be created using
      #                  geographic (default) or geometric coordinates
      # @return [RGeo::Polygon or RGeo::MultiPolygon]
      #   The buffer of size `buffer` around geographic_item_id
      def st_buffer_for_item(geographic_item_id, buffer, geometric: false)
        geometric = geometric ? '::geometry' : ''

        GeographicItem.select(
          'ST_Buffer(' \
            "#{GeographicItem::GEOGRAPHY_SQL}#{geometric}, " \
            "#{buffer}" \
          ') AS buffer'
        )
        .where(id: geographic_item_id)
        .first.buffer
      end

      def st_distance_sql(shape_sql)
        'ST_Distance(' \
          "#{GeographicItem::GEOGRAPHY_SQL}, " \
          "(#{shape_sql})" \
        ')'
      end

      def st_area_sql(shape_sql)
        'ST_Area(' \
          "(#{shape_sql})" \
        ')'
      end

      def st_isvalid_sql(shape_sql)
        'ST_IsValid(' \
          "(#{shape_sql})" \
        ')'
      end


      def st_isvalidreason_sql(shape_sql)
        'ST_IsValidReason(' \
          "(#{shape_sql})" \
        ')'
      end

      def st_astext_sql(shape_sql)
        'ST_AsText(' \
          "(#{shape_sql})" \
        ')'
      end

      def st_minimumboundingradius_sql(shape_sql)
        'ST_MinimumBoundingRadius(' \
          "(#{shape_sql})" \
        ')'
      end

      # True for those shapes that are within `distance` of (i.e. intersect the
      # `distance`-buffer of) the shape_sql shape. This is a geography dwithin,
      # distance is in meters.
      def st_dwithin_sql(shape_sql, distance)
        'ST_DWithin(' \
            "(#{GeographicItem::GEOGRAPHY_SQL}), " \
            "(#{shape_sql}), " \
            "#{distance}" \
          ')'
      end

      def st_asgeojson_sql(shape_sql)
        "ST_AsGeoJSON(#{shape_sql})"
      end

      # @param [String] wkt
      # @return [Boolean]
      #   whether or not the wkt intersects with the anti-meridian
      #   !! StrongParams security considerations
      def crosses_anti_meridian?(wkt)
        GeographicItem.find_by_sql(
          ['SELECT ST_Intersects(ST_GeogFromText(?), ST_GeogFromText(?)) as r;', wkt, ANTI_MERIDIAN]
        ).first.r
      end

      #
      # SQL fragments
      #

      # @param [Integer, String]
      # @return [String]
      #   a SQL select statement that returns the *geometry* for the
      #   geographic_item with the specified id
      def select_geometry_sql(geographic_item_id)
        "SELECT #{GeographicItem::GEOMETRY_SQL.to_sql} from geographic_items where geographic_items.id = #{geographic_item_id}"
      end

      # @param [Integer, String]
      # @return [String]
      #   a SQL select statement that returns the geography for the
      #   geographic_item with the specified id
      def select_geography_sql(geographic_item_id)
        ActiveRecord::Base.send(:sanitize_sql_for_conditions, [
          "SELECT #{GeographicItem::GEOGRAPHY_SQL} from geographic_items where geographic_items.id = ?",
          geographic_item_id])
      end

      # @param [Symbol] choice, either :latitude or :longitude
      # @return [String]
      #   a fragment returning either latitude or longitude columns
      def lat_long_sql(choice)
        return nil unless [:latitude, :longitude].include?(choice)
        f = "'D.DDDDDD'" # TODO: probably a constant somewhere
        v = (choice == :latitude ? 1 : 2)

      'CASE geographic_items.type ' \
      "WHEN 'GeographicItem::GeometryCollection' THEN split_part(ST_AsLatLonText(ST_Centroid" \
      "(geometry_collection::geometry), #{f}), ' ', #{v})
      WHEN 'GeographicItem::LineString' THEN split_part(ST_AsLatLonText(ST_Centroid(line_string::geometry), " \
      "#{f}), ' ', #{v})
      WHEN 'GeographicItem::MultiPolygon' THEN split_part(ST_AsLatLonText(" \
      "ST_Centroid(multi_polygon::geometry), #{f}), ' ', #{v})
      WHEN 'GeographicItem::Point' THEN split_part(ST_AsLatLonText(" \
      "ST_Centroid(point::geometry), #{f}), ' ', #{v})
      WHEN 'GeographicItem::Polygon' THEN split_part(ST_AsLatLonText(" \
      "ST_Centroid(polygon::geometry), #{f}), ' ', #{v})
      WHEN 'GeographicItem::MultiLineString' THEN split_part(ST_AsLatLonText(" \
      "ST_Centroid(multi_line_string::geometry), #{f} ), ' ', #{v})
      WHEN 'GeographicItem::MultiPoint' THEN split_part(ST_AsLatLonText(" \
      "ST_Centroid(multi_point::geometry), #{f}), ' ', #{v})
      WHEN 'GeographicItem::GeometryCollection' THEN split_part(ST_AsLatLonText(" \
      "ST_Centroid(geometry_collection::geometry), #{f}), ' ', #{v})
      WHEN 'GeographicItem::Geography' THEN split_part(ST_AsLatLonText(" \
      "ST_Centroid(geography::geometry), #{f}), ' ', #{v})
    END as #{choice}"
      end

      # @param [Integer] geographic_item_id
      # @param [Integer] distance in meters
      # @return [Scope] of shapes within distance of (i.e. whose
      #   distance-buffer intersects) geographic_item_id
      def within_radius_of_item_sql(geographic_item_id, distance)
        self.st_dwithin_sql(
          "#{select_geography_sql(geographic_item_id)}",
          distance
        )
      end

      def within_radius_of_item(geographic_item_id, distance)
        where(within_radius_of_item_sql(geographic_item_id, distance))
      end

      # @param [Integer] geographic_item_id
      # @param [Number] distance (in meters) (positive only?!)
      # @param [Number] buffer: distance in meters to grow/shrink the shapes checked against (negative allowed)
      # @return [String]
      def st_buffer_st_within(geographic_item_id, distance, buffer = 0)
        # You can't always switch the buffer to the second argument, even when
        # distance is 0, without further assumptions (think of buffer being
        # large negative compared to geographic_item_id, but not another shape))
        'ST_DWithin(' \
          "ST_Buffer(#{GeographicItem::GEOGRAPHY_SQL}, #{buffer}), " \
          "(#{select_geography_sql(geographic_item_id)}), " \
          "#{distance}" \
        ')'
      end

      # TODO: 3D is overkill here
      # @param [String] wkt
      # @param [Integer] distance (meters)
      # @return [String] Shapes within distance of (i.e. whose
      #   distance-buffer intersects) wkt
      def intersecting_radius_of_wkt_sql(wkt, distance)
        self.st_dwithin_sql(
          "ST_GeographyFromText('#{wkt}')",
          distance
        )
      end

      # @param [String] wkt
      # @param [Integer] distance (meters)
      # @return [String] Those items within the distance-buffer of wkt
      def within_radius_of_wkt(wkt, distance)
        where(self.within_sql(
          "ST_Buffer(ST_GeographyFromText('#{wkt}'), #{distance})"
        ))
      end

      # @param [String, Integer, String]
      # @return [String]
      #   a SQL fragment for ST_Covers() function, returns
      #   all geographic items whose target_shape covers the item supplied's
      #   source_shape
      def st_covers_sql(target_shape = nil, geographic_item_id = nil,
                               source_shape = nil)
        return 'false' if geographic_item_id.nil? || source_shape.nil? || target_shape.nil?

        target_shape_sql = GeographicItem.shape_column_sql(target_shape)

        'ST_Covers(' \
          "#{target_shape_sql}::geometry, " \
          "(#{geometry_sql(geographic_item_id, source_shape)})" \
        ')'
      end

      # @param [String, Integer, String]
      # @return [String]
      #   a SQL fragment for ST_Covers() function, returns
      #   all geographic items whose target_shape is covered by the item
      #   supplied's source_shape
      def st_coveredby_sql(target_shape = nil, geographic_item_id = nil, source_shape = nil)
        return 'false' if geographic_item_id.nil? || source_shape.nil? || target_shape.nil?

        target_shape_sql = GeographicItem.shape_column_sql(target_shape)

        'ST_CoveredBy(' \
          "#{target_shape_sql}::geometry, " \
          "(#{geometry_sql(geographic_item_id, source_shape)})" \
        ')'
      end

      # @param [Integer, String]
      # @return [String]
      #   a SQL fragment that returns the column containing data of the given
      #   shape for the specified geographic item
      def geometry_sql(geographic_item_id = nil, shape = nil)
        return 'false' if geographic_item_id.nil? || shape.nil?

        "SELECT #{GeographicItem.shape_column_sql(shape)}::geometry FROM " \
          "geographic_items WHERE id = #{geographic_item_id}"
      end

      # @param [Integer, Array of Integer] geographic_item_ids
      # @return [String]
      #    returns one or more geographic items combined as a single geometry
      #    in a paren wrapped column 'single_geometry'
      def single_geometry_sql(*geographic_item_ids)
        geographic_item_ids.flatten!
        q = ActiveRecord::Base.send(:sanitize_sql_for_conditions, [
          "SELECT ST_Collect(f.the_geom) AS single_geometry
          FROM (
            SELECT (
              ST_DUMP(#{GeographicItem::GEOMETRY_SQL.to_sql})
            ).geom AS the_geom
            FROM geographic_items
            WHERE id in (?)
          ) AS f",
          geographic_item_ids
        ])

      '(' + q + ')'
      end

      # @param [Integer, Array of Integer] geographic_item_ids
      # @return [String]
      #   returns a single geometry "column" (paren wrapped) as
      #   "single_geometry" for multiple geographic item ids, or the geometry
      #   as 'geometry' for a single id
      def items_as_one_geometry_sql(*geographic_item_ids)
        geographic_item_ids.flatten! # *ALWAYS* reduce the pile to a single level of ids
        if geographic_item_ids.count == 1
          "(#{GeographicItem.geometry_for_sql(geographic_item_ids.first)})"
        else
          GeographicItem.single_geometry_sql(geographic_item_ids)
        end
      end

      # @params [String] well known text
      # @return [String] the SQL fragment for the specific geometry type,
      # shifted by longitude
      # Note: this routine is called when it is already known that the A
      # argument crosses anti-meridian
      def covered_by_wkt_shifted_sql(wkt)
        "ST_CoveredBy(
          (CASE geographic_items.type
            WHEN 'GeographicItem::MultiPolygon' THEN ST_ShiftLongitude(multi_polygon::geometry)
            WHEN 'GeographicItem::Point' THEN ST_ShiftLongitude(point::geometry)
            WHEN 'GeographicItem::LineString' THEN ST_ShiftLongitude(line_string::geometry)
            WHEN 'GeographicItem::Polygon' THEN ST_ShiftLongitude(polygon::geometry)
            WHEN 'GeographicItem::MultiLineString' THEN ST_ShiftLongitude(multi_line_string::geometry)
            WHEN 'GeographicItem::MultiPoint' THEN ST_ShiftLongitude(multi_point::geometry)
            WHEN 'GeographicItem::GeometryCollection' THEN ST_ShiftLongitude(geometry_collection::geometry)
            WHEN 'GeographicItem::Geography' THEN ST_ShiftLongitude(geography::geometry)
          END),
          ST_ShiftLongitude(ST_GeomFromText('#{wkt}', 4326)),
        )"
      end

      # TODO: Remove the hard coded 4326 reference
      # @params [String] wkt
      # @return [String] SQL fragment limiting geographic items to those
      # covered by this WKT
      def covered_by_wkt_sql(wkt)
        if crosses_anti_meridian?(wkt)
          covered_by_wkt_shifted_sql(wkt)
        else
          self.within_sql("ST_GeomFromText('#{wkt}', 4326)")
        end
      end

      # @param [Integer] geographic_item_id
      # @return [String] SQL for geometries
      def geometry_for_sql(geographic_item_id)
        'SELECT ' + GeographicItem::GEOMETRY_SQL.to_sql + ' AS geometry FROM geographic_items WHERE id = ' \
          "#{geographic_item_id} LIMIT 1"
      end

      #
      # Scopes
      #

      # @param [RGeo::Point] rgeo_point
      # @return [Scope]
      #    the geographic items covering this point
      # TODO: should be covering_wkt ?
      def covering_point(rgeo_point)
        where(
          self.covering_sql("ST_GeomFromText('#{rgeo_point}', 4326)")
        )
      end

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

      # @return [Scope]
      def intersecting(shape, *geographic_item_ids)
        shape = shape.to_s.downcase
        if shape == 'any'
          pieces = []
          SHAPE_TYPES.each { |shape|
            pieces.push(
              GeographicItem.intersecting(shape, geographic_item_ids).to_a
            )
          }

          # @TODO change 'id in (?)' to some other sql construct
          GeographicItem.where(id: pieces.flatten.map(&:id))
        else
          shape_column = GeographicItem.shape_column_sql(shape)
          q = geographic_item_ids.flatten.collect { |geographic_item_id|
            # seems like we want this: http://danshultz.github.io/talks/mastering_activerecord_arel/#/15/2
            'ST_Intersects(' \
              "#{shape_column}::geometry, " \
              "(#{self.select_geometry_sql(geographic_item_id)})" \
            ')'
          }.join(' or ')

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
      # @return [Scope] of GeographicItems whose `shape` covers at least one of
      #                 geographic_items
      #
      # If this scope is given an Array of GeographicItems as a second parameter,
      # it will return the 'OR' of each of the objects against the table.
      # SELECT COUNT(*) FROM "geographic_items"
      #        WHERE (ST_Covers(polygon::geometry, GeomFromEWKT('srid=4326;POINT (0.0 0.0 0.0)'))
      #               OR ST_Covers(polygon::geometry, GeomFromEWKT('srid=4326;POINT (-9.8 5.0 0.0)')))
      #
      def st_covers(shape, *geographic_items)
        geographic_items.flatten! # in case there is a array of arrays, or multiple objects
        shape = shape.to_s.downcase
        case shape
        when 'any'
          part = []
          SHAPE_TYPES.each { |shape|
            part.push(GeographicItem.st_covers(shape, geographic_items).to_a)
          }
          # TODO: change 'id in (?)' to some other sql construct
          GeographicItem.where(id: part.flatten.map(&:id))

        when 'any_poly', 'any_line'
          part = []
          SHAPE_TYPES.each { |shape|
            shape = shape.to_s
            if shape.index(shape.gsub('any_', ''))
              part.push(GeographicItem.st_covers(shape, geographic_items).to_a)
            end
          }
          # TODO: change 'id in (?)' to some other sql construct
          GeographicItem.where(id: part.flatten.map(&:id))

        else
          q = geographic_items.flatten.collect { |geographic_item|
            GeographicItem.st_covers_sql(
              shape,
              geographic_item.id,
              geographic_item.geo_object_type
            )
          }.join(' or ')

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
      # @return [Scope] of all GeographicItems of the given `shape  ` covered by
      # one or more of geographic_items
      def st_coveredby(shape, *geographic_items)
        shape = shape.to_s.downcase
        case shape
        when 'any'
          part = []
          SHAPE_TYPES.each { |shape|
            part.push(GeographicItem.st_coveredby(shape, geographic_items).to_a)
          }
          # @TODO change 'id in (?)' to some other sql construct
          GeographicItem.where(id: part.flatten.map(&:id))

        when 'any_poly', 'any_line'
          part = []
          SHAPE_TYPES.each { |shape|
            shape = shape.to_s
            if shape.index(shape.gsub('any_', ''))
              part.push(GeographicItem.st_coveredby(shape, geographic_items).to_a)
            end
          }
          # @TODO change 'id in (?)' to some other sql construct
          GeographicItem.where(id: part.flatten.map(&:id))

        else
          q = geographic_items.flatten.collect { |geographic_item|
            GeographicItem.st_coveredby_sql(
              shape,
              geographic_item.id,
              geographic_item.geo_object_type
            )
          }.join(' or ')
          where(q) # .not_including(geographic_items)
        end
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

      # @param [Integer] geographic_item_id1
      # @param [Integer] geographic_item_id2
      # @return [Float]
      def distance_between(geographic_item_id1, geographic_item_id2)
        q = self.st_distance_sql(
          self.select_geography_sql(geographic_item_id2)
        )

        GeographicItem.where(id: geographic_item_id1).pick(Arel.sql(q))
      end

      # @param [RGeo::Point] point
      # @return [Hash]
      #   as per #inferred_geographic_name_hierarchy but for Rgeo point
      def point_inferred_geographic_name_hierarchy(point)
        self
          .covering_point(point)
          .order(cached_total_area: :ASC)
          .first&.inferred_geographic_name_hierarchy
      end

      # @param [String] type_name ('polygon', 'point', 'line', etc)
      # @return [String] if type
      def eval_for_type(type_name)
        retval = 'GeographicItem'
        case type_name.upcase
        when 'POLYGON'
          retval += '::Polygon'
        when 'MULTIPOLYGON'
          retval += '::MultiPolygon'
        when 'LINESTRING'
          retval += '::LineString'
        when 'MULTILINESTRING'
          retval += '::MultiLineString'
        when 'POINT'
          retval += '::Point'
        when 'MULTIPOINT'
          retval += '::MultiPoint'
        when 'GEOMETRYCOLLECTION'
          retval += '::GeometryCollection'
        when 'GEOGRAPHY'
          retval += '::Geography'
        else
          retval = nil
        end
        retval
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
        "JOIN (#{GeographicItem.covering_union_of(id).to_sql}) AS j ON " \
        'geographic_items.id = j.id'
      )
    end

    # @return [Boolean]
    #   whether stored shape is ST_IsValid
    def valid_geometry?
      GeographicItem
      .where(id:)
      .select(
        self.class.st_isvalid_sql("ST_AsBinary(#{data_column})")
      ).first['st_isvalid']
    end

    # @return [Array]
    #   the lat, long, as STRINGs for the centroid of this geographic item
    #   Meh- this: https://postgis.net/docs/en/ST_MinimumBoundingRadius.html
    def center_coords
      r = GeographicItem.find_by_sql(
        "Select split_part(ST_AsLatLonText(ST_Centroid(#{GeographicItem::GEOMETRY_SQL.to_sql}), " \
        "'D.DDDDDD'), ' ', 1) latitude, split_part(ST_AsLatLonText(ST_Centroid" \
        "(#{GeographicItem::GEOMETRY_SQL.to_sql}), 'D.DDDDDD'), ' ', 2) " \
        "longitude from geographic_items where id = #{id};")[0]

      [r.latitude, r.longitude]
    end

    # @return [RGeo::Geographic::ProjectedPointImpl]
    #    representing the centroid of this geographic item
    def centroid
      # Gis::FACTORY.point(*center_coords.reverse)
      return geo_object if geo_object_type == :point
      return Gis::FACTORY.parse_wkt(st_centroid)
    end

    # @param [GeographicItem] geographic_item
    # @return [Double] distance in meters
    # Like st_distance but works with changed and non persisted objects
    def st_distance_to_geographic_item(geographic_item)
      unless !persisted? || changed?
        a = "(#{GeographicItem.select_geography_sql(id)})"
      else
        a = "ST_GeographyFromText('#{geo_object}')"
      end

      unless !geographic_item.persisted? || geographic_item.changed?
        b = "(#{GeographicItem.select_geography_sql(geographic_item.id)})"
      else
        b = "ST_GeographyFromText('#{geographic_item.geo_object}')"
      end

      ActiveRecord::Base.connection.select_value("SELECT ST_Distance(#{a}, #{b})")
    end

    # @param [Integer] geographic_item_id
    # @return [Double] distance in meters
    def st_distance_spheroid(geographic_item_id)
      q = 'ST_DistanceSpheroid(' \
            "(#{GeographicItem.select_geometry_sql(id)}), " \
            "(#{GeographicItem.select_geometry_sql(geographic_item_id)}) ," \
            "'#{Gis::SPHEROID}'" \
          ') as distance'
      GeographicItem.where(id:).pick(Arel.sql(q))
    end

    # @return [String]
    #   a WKT POINT representing the centroid of the geographic item
    def st_centroid
      GeographicItem.where(id:).pick(Arel.sql("ST_AsEWKT(ST_Centroid(#{GeographicItem::GEOMETRY_SQL.to_sql}))")).gsub(/SRID=\d*;/, '')
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

    # @return [GeoJSON hash]
    #    via Rgeo apparently necessary for GeometryCollection
    def rgeo_to_geo_json
      RGeo::GeoJSON.encode(geo_object).to_json
    end

    # @return [Hash] in GeoJSON format
    def to_geo_json
      JSON.parse(
        select_self(
          self.class.st_asgeojson_sql(data_column)
        )['st_asgeojson']
      )
    end

    # @return [Hash]
    #   the shape as a GeoJSON Feature with some item metadata
    def to_geo_json_feature
      @geometry ||= to_geo_json
      {'type' => 'Feature',
       'geometry' => geometry,
       'properties' => {
         'geographic_item' => {
           'id' => id}
       }
      }
    end

    # @param value [String] like:
    #   '{"type":"Feature","geometry":{"type":"Point","coordinates":[2.5,4.0]},"properties":{"color":"red"}}'
    #
    #   '{"type":"Feature","geometry":{"type":"Polygon","coordinates":"[[[-125.29394388198853, 48.584480409793],
    #      [-67.11035013198853, 45.09937589848195],[-80.64550638198853, 25.01924647619111],[-117.55956888198853,
    #      32.5591595028449],[-125.29394388198853, 48.584480409793]]]"},"properties":{}}'
    #
    #  '{"type":"Point","coordinates":[2.5,4.0]},"properties":{"color":"red"}}'
    #
    # @return [RGeo object]
    def shape=(value)
      return if value.blank?

      begin
        geom = RGeo::GeoJSON.decode(value, json_parser: :json, geo_factory: Gis::FACTORY)
      rescue RGeo::Error::InvalidGeometry => e
        errors.add(:base, "invalid geometry: #{e}")
        return
      end

      this_type = nil

      if geom.respond_to?(:properties) && geom.properties['data_type'].present?
        this_type = geom.properties['data_type']
      elsif geom.respond_to?(:geometry_type)
        this_type = geom.geometry_type.to_s
      elsif geom.respond_to?(:geometry)
        this_type = geom.geometry.geometry_type.to_s
      else
      end

      self.type = GeographicItem.eval_for_type(this_type) unless geom.nil?

      if type.blank?
        errors.add(:base, "unrecognized geometry type '#{this_type}'")
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

      write_attribute(this_type.underscore.to_sym, object)
      geom
    end

    # @return [String] wkt
    def to_wkt
      #  10k  #<Benchmark::Tms:0x00007fb0dfd30fd0 @label="", @real=25.237487000005785, @cstime=0.0, @cutime=0.0, @stime=1.1704609999999995, @utime=5.507929999999988, @total=6.678390999999987>
      #  GeographicItem.select("ST_AsText( #{GeographicItem::GEOMETRY_SQL.to_sql}) wkt").where(id: id).first.wkt

      # 10k <Benchmark::Tms:0x00007fb0e02f7540 @label="", @real=21.619827999995323, @cstime=0.0, @cutime=0.0, @stime=0.8850890000000007, @utime=3.2958549999999605, @total=4.180943999999961>
      if (a = select_self(
          self.class.st_astext_sql(GeographicItem::GEOMETRY_SQL.to_sql)
      ))
        return a['st_astext']
      else
        return nil
      end
    end

    # @return  [Float] in meters, calculated
    # TODO: share with world
    #    Geographic item 96862 (Cajamar in Brazil) is the only(?) record to fail using `false` (quicker) method of everything we tested
    def area
      # TODO use select_self
      a = GeographicItem.where(id:).select(
        self.class.st_area_sql(GeographicItem::GEOGRAPHY_SQL)
      ).first['st_area']

      a = nil if a.nan?
      a
    end

    # TODO: This is bad, while internal use of ONE_WEST_MEAN is consistent it is in-accurate given the vast differences of radius vs. lat/long position.
    # When we strike the error-polygon from radius we should remove this
    #
    # Use case is returning the radius from a circle we calculated via buffer for error-polygon creation.
    def radius
      r = select_self(
        self.class.st_minimumboundingradius_sql(
          GeographicItem::GEOMETRY_SQL.to_sql
        )
      )['st_minimumboundingradius'].split(',').last.chop.to_f

      (r * Utilities::Geo::ONE_WEST_MEAN).to_i
    end

    # Convention is to store in PostGIS in CCW
    # @return Array [Boolean]
    #   false - cw
    #   true - ccw (preferred), except see donuts
    def orientations
      if (column = multi_polygon_column)
        ApplicationRecord.connection.execute(" \
             SELECT ST_IsPolygonCCW(a.geom) as is_ccw
                FROM ( SELECT b.id, (ST_Dump(p_geom)).geom AS geom
                   FROM (SELECT id, #{column}::geometry AS p_geom FROM geographic_items where id = #{id}) AS b \
              ) AS a;").collect{|a| a['is_ccw']}
      elsif (column = polygon_column)
        ApplicationRecord.connection.execute(
          "SELECT ST_IsPolygonCCW(#{column}::geometry) as is_ccw \
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

    def st_isvalid
      select_self(
        self.class.st_isvalid_sql(
          GeographicItem::GEOMETRY_SQL.to_sql
        )
      )['st_isvalid']
    end

    def st_isvalidreason
      select_self(
        self.class.st_isvalidreason_sql(
          GeographicItem::GEOMETRY_SQL.to_sql
        )
      )['st_isvalidreason']
    end

    # @return [Symbol, nil]
    #   the specific type of geography: :point, :multipolygon, etc. Returns
    #   the underlying shape of :geography in the :geography case
    def geo_object_type
      column = data_column

      return column == :geography ?
        geography.geometry_type.type_name.underscore.to_sym :
        column
    end

    # @return [RGeo instance, nil]
    #  the Rgeo shape (See http://rubydoc.info/github/dazuma/rgeo/RGeo/Feature)
    def geo_object
      column = data_column

      return column.nil? ? nil : send(column)
    end

    private

    # @return [Symbol]
    #   Returns the attribute (column name) containing data.
    #   Nearly all methods should use #geo_object_type instead.
    def data_column
      # This works before and after this item has been saved
      DATA_TYPES.each { |item|
        return item if send(item)
      }
      nil
    end

    def polygon_column
      geo_object_type == :polygon ? data_column : nil
    end

    def multi_polygon_column
      geo_object_type == :multi_polygon ? data_column : nil
    end

    # @param [String] shape, the type of shape you want
    # @return [String]
    #   A paren-wrapped SQL fragment for selecting the column containing
    #   the given shape (e.g. a polygon).
    #   Returns the column named :shape if no shape is found.
    #   !! This should probably never be called except to be put directly in a
    #   raw ST_* statement as the parameter that matches some shape.
    def self.shape_column_sql(shape)
      st_shape = 'ST_' + shape.to_s.camelize

      '(CASE ST_GeometryType(geography::geometry) ' \
      "WHEN '#{st_shape}' THEN geography " \
      "ELSE #{shape} END)"
    end

    # TODO select_from_self?
    def select_self(shape_sql)
      ApplicationRecord.connection.execute( "SELECT #{shape_sql} FROM geographic_items WHERE geographic_items.id = #{id}").first
    end

    def align_winding
      if orientations.flatten.include?(false)
        if (column = multi_polygon_column)
          column = column.to_s
          ApplicationRecord.connection.execute(
            "UPDATE geographic_items set #{column} = ST_ForcePolygonCCW(#{column}::geometry)
              WHERE id = #{self.id};"
           )
        elsif (column = polygon_column)
          column = column.to_s
          ApplicationRecord.connection.execute(
            "UPDATE geographic_items set #{column} = ST_ForcePolygonCCW(#{column}::geometry)
              WHERE id = #{self.id};"
           )
        end
      end
      true
    end

    # Crude debuging helper, write the shapes
    # to a png
    def self.debug_draw(geographic_item_ids = [])
      return false if geographic_item_ids.empty?
      # TODO support other shapes
      sql = "SELECT ST_AsPNG(
         ST_AsRaster(
            (SELECT ST_Union(multi_polygon::geometry) from geographic_items where id IN (" + geographic_item_ids.join(',') + ")), 1920, 1080
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

    def set_type_if_shape_column_present
      if type.blank?
        column = data_column
        self.type = "GeographicItem::#{column.to_s.camelize}" if column
      end
    end

    # @return [Boolean] iff there is one and only one shape column set
    def some_data_is_provided
      data = []

      DATA_TYPES.each do |item|
        data.push(item) if send(item).present?
      end

      case data.count
      when 0
        errors.add(:base, 'No shape provided or provided shape is invalid')
      when 1
        return true
      else
        data.each do |object|
          errors.add(object, 'More than one shape type provided')
        end
      end
      false
    end
end

    #     Dir[Rails.root.to_s + '/app/models/geographic_item/**/*.rb'].each { |file| require_dependency file }
