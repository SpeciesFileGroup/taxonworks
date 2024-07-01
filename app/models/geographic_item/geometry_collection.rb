# Geometry collection definition...
#
class GeographicItem::GeometryCollection < GeographicItem
  validates_presence_of :geometry_collection

  # @return [RGeo::Point] first point in the collection
  def st_start_point
    rgeo_to_geo_json =~ /(-?\d+\.?\d*),(-?\d+\.?\d*)/
    Gis::FACTORY.point($1.to_f, $2.to_f, 0.0)
  end

  # @return [Hash]
  def rendering_hash
    to_hash(self.geometry_collection)
  end

  # @todo Seems to be deprecated for rgeo_to_geo_json?!
  # @param [GeometryCollection]
  # @return [Hash] a simple representation of the collection in points, lines, and polygons.
  def to_hash(geometry_collection)
    data = {
      points:   [],
      lines:    [],
      polygons: []
    }
    geometry_collection.each { |it|
      case it.geometry_type.type_name
      when 'Point'
        # POINT (-88.241421 40.091565 757.0)
        point = point_to_hash(it)[:points]
        # @todo would it really be better to use object_to_hash here?  Structure-wise, perhaps, but it really is faster to do it here directly, I think...
        data[:points].push(point_to_a(it))
      when /^Line[S]*/ #when 'Line' or 'LineString'
        # LINESTRING (-32.0 21.0 0.0, -25.0 21.0 0.0, -25.0 16.0 0.0, -21.0 20.0 0.0)
        data[:lines].push(line_string_to_a(it))
      when 'Polygon'
        # POLYGON ((-14.0 23.0 0.0, -14.0 11.0 0.0, -2.0 11.0 0.0, -2.0 23.0 0.0, -8.0 21.0 0.0, -14.0 23.0 0.0), (-11.0 18.0 0.0, -8.0 17.0 0.0, -6.0 20.0 0.0, -4.0 16.0 0.0, -7.0 13.0 0.0, -11.0 14.0 0.0, -11.0 18.0 0.0))
        # note: only the exterior_ring is processed
        data[:polygons].push(polygon_to_a(it))
        # in the cases of the multi-objects, break each down to its constituent parts (i.e., remove its identity as a multi-whatever), and record those parts
      when 'MultiPoint'
        # MULTIPOINT ((3.0 -14.0 0.0), (6.0 -12.9 0.0), (5.0 -16.0 0.0), (4.0 -17.9 0.0), (7.0 -17.9 0.0))
        multi_point_to_a(it).each { |point|
          data[:points].push(point)
        }
      when 'MultiLineString'
        # MULTILINESTRING ((23.0 21.0 0.0, 16.0 21.0 0.0, 16.0 16.0 0.0, 11.0 20.0 0.0), (4.0 12.6 0.0, 16.0 12.6 0.0, 16.0 7.6 0.0), (21.0 12.6 0.0, 26.0 12.6 0.0, 22.0 17.6 0.0))
        multi_line_string_to_a(it).each { |line_string|
          data[:lines].push(line_string)
        }
      when 'MultiPolygon'
        # MULTIPOLYGON (((28.0 2.3 0.0, 23.0 -1.7 0.0, 26.0 -4.8 0.0, 28.0 2.3 0.0))
        it.each { |polygon|
          polygon_data = []
          polygon.exterior_ring.points.each { |point|
            polygon_data.push([point.x, point.y]) }
          data[:polygons].push(polygon_data)
        }
      when 'GeometryCollection'
        collection_hash = to_hash(it)
        collection_hash.each_key { |key|
          collection_hash[key].each { |item|
            data[key].push(item) }
        }
      else
        # leave everything as it is...
      end
    }
    # remove any keys with empty arrays
    data.delete_if { |key, value| value == [] }
    data
  end

  # @return [GeoJSON Feature]
  # the shape as a Feature/Feature Collection
  def to_geo_json_feature
    self.geometry = rgeo_to_geo_json
    super
  end

end
