module GeographicItem::Deprecated
  extend ActiveSupport::Concern

  #
  # GeographicItem methods that are currently unused or used only in specs
  #

  class_methods do
      # DEPRECATED
    def st_collect(geographic_item_scope)
      GeographicItem.select("ST_Collect(#{GeographicItem::GEOMETRY_SQL.to_sql}) as collection")
        .where(id: geographic_item_scope.pluck(:id))
    end

    # DEPRECATED, used only in specs
    # @param [Integer, Array of Integer] geographic_item_ids
    # @return [Scope]
    #    the geographic items contained by the union of these
    #    geographic_item ids; return value always includes geographic_item_ids
    # (works via ST_Contains)
    def contained_by(*geographic_item_ids)
      where(GeographicItem.contained_by_where_sql(geographic_item_ids))
    end


    # DEPRECATED
    # @return [GeographicItem::ActiveRecord_Relation]
    # @params [Array] array of geographic area ids
    def default_by_geographic_area_ids(geographic_area_ids = [])
      GeographicItem.
        joins(:geographic_areas_geographic_items).
        merge(::GeographicAreasGeographicItem.default_geographic_item_data).
        where(geographic_areas_geographic_items: {geographic_area_id: geographic_area_ids})
    end

    # DEPRECATED
    # @param [Integer] ids
    # @return [Boolean]
    #   whether or not any GeographicItem passed intersects the anti-meridian
    #   !! StrongParams security considerations
    #   This is our first line of defense against queries that define multiple shapes, one or
    #   more of which crosses the anti-meridian.  In this case the current TW strategy within the
    #   UI is to abandon the search, and prompt the user to refactor the query.
    def crosses_anti_meridian_by_id?(*ids)
      q = "SELECT ST_Intersects((SELECT single_geometry FROM (#{GeographicItem.single_geometry_sql(*ids)}) as " \
            'left_intersect), ST_GeogFromText(?)) as r;', ANTI_MERIDIAN
      GeographicItem.find_by_sql([q]).first.r
    end

    # DEPRECATED
    # rubocop:disable Metrics/MethodLength
    # @param [String] shape
    # @param [GeographicItem] geographic_item
    # @return [String] of SQL for all GeographicItems of the given shape
    # contained by geographic_item
    def is_contained_by_sql(shape, geographic_item)
      template = "(ST_Contains(#{geographic_item.geo_object}, %s::geometry))"
      retval = []
      shape = shape.to_s.downcase
      case shape
      when 'any'
        SHAPE_TYPES.each { |shape|
          shape_column = GeographicItem.shape_column_sql(shape)
          retval.push(template % shape_column)
        }

      when 'any_poly', 'any_line'
        SHAPE_TYPES.each { |shape|
          if column.to_s.index(shape.gsub('any_', ''))
            shape_column = GeographicItem.shape_column_sql(shape)
            retval.push(template % shape_column)
          end
        }

      else
        shape_column = GeographicItem.shape_column_sql(shape)
        retval = template % shape_column
      end
      retval = retval.join(' OR ') if retval.instance_of?(Array)
      retval
    end
    # rubocop:enable Metrics/MethodLength

    # DEPRECATED
    # @param [Integer, Array of Integer] geographic_item_ids
    # @return [String]
    # Result doesn't contain self. Much slower than containing_where_sql
    def containing_where_sql_geog(*geographic_item_ids)
      "ST_CoveredBy(
        (#{GeographicItem.geometry_sql2(*geographic_item_ids)})::geography,
        #{GEOGRAPHY_SQL})"
    end

    # DEPRECATED
    # @param [Interger, Array of Integer] ids
    # @return [Array]
    #   If we detect that some query id has crossed the meridian, then loop through
    #   and "manually" build up a list of results.
    #   Should only be used if GeographicItem.crosses_anti_meridian_by_id? is true.
    #   Note that this does not return a Scope, so you can't chain it like contained_by?
    # TODO: test this
    def contained_by_with_antimeridian_check(*ids)
      ids.flatten! # make sure there is only one level of splat (*)
      results = []

      crossing_ids = []

      ids.each do |id|
        # push each which crosses
        crossing_ids.push(id) if GeographicItem.crosses_anti_meridian_by_id?(id)
      end

      non_crossing_ids = ids - crossing_ids
      results.push GeographicItem.contained_by(non_crossing_ids).to_a if non_crossing_ids.any?

      crossing_ids.each do |id|
        # [61666, 61661, 61659, 61654, 61639]
        q1 = ActiveRecord::Base.send(:sanitize_sql_array, ['SELECT ST_AsText((SELECT polygon FROM geographic_items ' \
                                                            'WHERE id = ?))', id])
        r = GeographicItem.where(
          # GeographicItem.contained_by_wkt_shifted_sql(GeographicItem.find(id).geo_object.to_s)
          GeographicItem.contained_by_wkt_shifted_sql(
            ApplicationRecord.connection.execute(q1).first['st_astext'])
        ).to_a
        results.push(r)
      end

      results.flatten.uniq
    end

    # DEPRECATED
    # @param [Integer, Array of Integer] geographic_item_ids
    # @return [String] SQL for geometries
    # example, not used
    def geometry_for_collection_sql(*geographic_item_ids)
      'SELECT ' + GeographicItem::GEOMETRY_SQL.to_sql + ' AS geometry FROM geographic_items WHERE id IN ' \
        "( #{geographic_item_ids.join(',')} )"
    end

    # DEPRECATED
    # @return [Scope]
    #   adds an area_in_meters field, with meters
    def with_area
      select("ST_Area(#{GeographicItem::GEOGRAPHY_SQL}, false) as area_in_meters")
    end

    # DEPRECATED
    # @return [Scope] include a 'latitude' column
    def with_latitude
      select(lat_long_sql(:latitude))
    end

    # DEPRECATED
    # @return [Scope] include a 'longitude' column
    def with_longitude
      select(lat_long_sql(:longitude))
    end

    # DEPRECATED, used only in specs to test itself
    # @param [String, GeographicItem]
    # @return [Scope]
    #   a SQL fragment for ST_DISJOINT, specifies geographic_items of the
    #   given shape that are disjoint from all of the passed
    #   geographic_items
    def disjoint_from(shape, *geographic_items)
      shape_column = GeographicItem.shape_column_sql(shape)

      q = geographic_items.flatten.collect { |geographic_item|
        geographic_item_geometry = geometry_sql(geographic_item.id,
          geographic_item.geo_object_type)

        "ST_DISJOINT(#{shape_column}::geometry, " \
                    "(#{geographic_item_geometry}))"
      }.join(' and ')

      where(q)
    end

    # DEPRECATED
    # @param [String] shape
    # @param [String] geometry of WKT
    # @return [Scope]
    # A scope of GeographicItems of the given shape contained in the
    # WKT.
    def are_contained_in_wkt(shape, geometry)
      shape = shape.to_s.downcase
      case shape
      when 'any'
        part = []
        SHAPE_TYPES.each { |shape|
          part.push(GeographicItem.are_contained_in_wkt(shape, geometry).pluck(:id).to_a)
        }
        # TODO: change 'id in (?)' to some other sql construct
        GeographicItem.where(id: part.flatten)

      when 'any_poly', 'any_line'
        part = []
        SHAPE_TYPES.each { |shape|
          if shape.to_s.index(shape.gsub('any_', ''))
            part.push(GeographicItem.are_contained_in_wkt("#{shape}", geometry).pluck(:id).to_a)
          end
        }
        # TODO: change 'id in (?)' to some other sql construct
        GeographicItem.where(id: part.flatten)

      else
        where(
          'ST_Contains(' \
            "ST_GeomFromEWKT('srid=4326;#{geometry}'), " \
            "#{GeographicItem.shape_column_sql(shape)}::geometry" \
          ')'
        ) # .not_including(geographic_items)
      end
    end

  end # class_methods

  # Used only in specs
  # @param [Integer] geographic_item_id
  # @return [Double] distance in meters
  def st_distance(geographic_item_id) # geo_object
    q = 'ST_Distance(' \
            "(#{GeographicItem.select_geography_sql(id)}), " \
            "(#{GeographicItem.select_geography_sql(geographic_item_id)})" \
          ') as d'

    GeographicItem.where(id:).pick(Arel.sql(q))
  end

  # DEPRECATED
  alias_method :distance_to, :st_distance

  # DEPRECATED, used only in specs to test itself
  # @param [geo_object, Double]
  # @return [Boolean]
  def near(target_geo_object, distance)
    self.geo_object.unsafe_buffer(distance).contains?(target_geo_object)
  end

  # DEPRECATED, used only in specs to test itself
  # @param [geo_object, Double]
  # @return [Boolean]
  def far(target_geo_object, distance)
    !near(target_geo_object, distance)
  end

  # DEPRECATED
  # We don't need to serialize to/from JSON
  def to_geo_json_string
    GeographicItem.connection.select_one(
      "SELECT ST_AsGeoJSON(#{geo_object_type}::geometry) a " \
      "FROM geographic_items WHERE id=#{id};"
    )['a']
  end

  # DEPRECATED
  # @return [Float, false]
  #    the value in square meters of the interesecting area of this and another GeographicItem
  def intersecting_area(geographic_item_id)
    self_shape = GeographicItem.select_geography_sql(id)
    other_shape = GeographicItem.select_geography_sql(geographic_item_id)

    r = GeographicItem.connection.execute(
      "SELECT ST_Area(ST_Intersection((#{self_shape}), (#{other_shape}))) " \
      'AS intersecting_area FROM geographic_items limit 1'
    ).first

    r && r['intersecting_area'].to_f
  end

  # DEPRECATED
  # !! Unused. Doesn't check Geometry collection or geography column
  def has_polygons?
    ['GeographicItem::MultiPolygon', 'GeographicItem::Polygon'].include?(self.type)
  end

  private

      # @param [RGeo::Point] point
  # @return [Array] of a point
  #   Longitude |, Latitude -
  def point_to_a(point)
    data = []
    data.push(point.x, point.y)
    data
  end

  # @param [RGeo::Point] point
  # @return [Hash] of a point
  def point_to_hash(point)
    {points: [point_to_a(point)]}
  end

  # @param [RGeo::MultiPoint] multi_point
  # @return [Array] of points
  def multi_point_to_a(multi_point)
    data = []
    multi_point.each { |point|
      data.push([point.x, point.y])
    }
    data
  end

  # @return [Hash] of points
  def multi_point_to_hash(_multi_point)
    # when we encounter a multi_point type, we only stick the points into the array, NOT it's identity as a group
    {points: multi_point_to_a(multi_point)}
  end

  # @param [Reo::LineString] line_string
  # @return [Array] of points in the line
  def line_string_to_a(line_string)
    data = []
    line_string.points.each { |point|
      data.push([point.x, point.y])
    }
    data
  end

  # @param [Reo::LineString] line_string
  # @return [Hash] of points in the line
  def line_string_to_hash(line_string)
    {lines: [line_string_to_a(line_string)]}
  end

  # @param [RGeo::Polygon] polygon
  # @return [Array] of points in the polygon (exterior_ring ONLY)
  def polygon_to_a(polygon)
    # TODO: handle other parts of the polygon; i.e., the interior_rings (if they exist)
    data = []
    polygon.exterior_ring.points.each { |point|
      data.push([point.x, point.y])
    }
    data
  end

  # @param [RGeo::Polygon] polygon
  # @return [Hash] of points in the polygon (exterior_ring ONLY)
  def polygon_to_hash(polygon)
    {polygons: [polygon_to_a(polygon)]}
  end

  # @return [Array] of line_strings as arrays of points
  # @param [RGeo::MultiLineString] multi_line_string
  def multi_line_string_to_a(multi_line_string)
    data = []
    multi_line_string.each { |line_string|
      line_data = []
      line_string.points.each { |point|
        line_data.push([point.x, point.y])
      }
      data.push(line_data)
    }
    data
  end

  # @return [Hash] of line_strings as hashes of points
  def multi_line_string_to_hash(_multi_line_string)
    {lines: to_a}
  end

  # @param [RGeo::MultiPolygon] multi_polygon
  # @return [Array] of arrays of points in the polygons (exterior_ring ONLY)
  def multi_polygon_to_a(multi_polygon)
    data = []
    multi_polygon.each { |polygon|
      polygon_data = []
      polygon.exterior_ring.points.each { |point|
        polygon_data.push([point.x, point.y])
      }
      data.push(polygon_data)
    }
    data
  end

  # @return [Hash] of hashes of points in the polygons (exterior_ring ONLY)
  def multi_polygon_to_hash(_multi_polygon)
    {polygons: to_a}
  end
end