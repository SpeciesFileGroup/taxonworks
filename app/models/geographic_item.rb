class GeographicItem < ActiveRecord::Base
  # TODO: Where would one put such code?
  # RGeo::Geos.preferred_native_interface = :ffi
  # RGeo::ActiveRecord::GeometryMixin.set_json_generator(:geojson)

  # include RGeo::ActiveRecord

  include Housekeeping::Users
 #  include ActiveRecordSpatial::SpatialColumns
 #  include ActiveRecordSpatial::SpatialScopes
 #  self.create_spatial_column_accessors! # except: ['point']


  DATA_TYPES = [:point,
                :line_string,
                :polygon,
                :multi_point,
                :multi_line_string,
                :multi_polygon,
                :geometry_collection]

# column_factory = RGeo::Geos.factory(
#   native_interface: :ffi,
#   srid:             4326,
#   has_z_coordinate: true,
#   has_m_coordinate: false)

  column_factory = Georeference::FACTORY

  DATA_TYPES.each do |t|
    set_rgeo_factory_for_column(t, column_factory)
  end

  has_many :gadm_geographic_areas, class_name: 'GeographicArea', foreign_key: :gadm_geo_item_id
  has_many :ne_geographic_areas, class_name: 'GeographicArea', foreign_key: :ne_geo_item_id
  has_many :tdwg_geographic_areas, class_name: 'GeographicArea', foreign_key: :tdwg_geo_item_id
  has_many :georeferences

  validate :proper_data_is_provided

 
  # FactoryGirl.create(:valid_geographic_item)
  # FactoryGirl.create(:valid_geographic_item)
  # FactoryGirl.create(:valid_geographic_item)
  # p = GeographicItem.first.geo_object
  #
  # GeographicItem.where{st_intersects(point, p)}.count

  # The last {} bit comes from Squeel and see bottom of https://github.com/neighborland/activerecord-postgis-adapter/blob/master/Documentation.rdoc


  scope :intersecting_boxes, -> (geographic_item) {
    select("ST_Contains(geographic_items.polygon, #{geographic_item.geo_object})",
          ) }

  def self.find_containing(geo_object)
    data = []
    GeographicItem.all.to_a.each { |area|
      if area.geo_object.contains?(geo_object)
        data.push(area)
      end
    }
    data
  end

  def self.clean!
    # create table t20140306(id int);
    # insert into t20140306 select id from geographic_items;

    # delete from t20140306 where id in (select ne_geo_item_id from geographic_areas where ne_geo_item_id is not null);
    # delete from t20140306 where id in (select tdwg_geo_item_id from geographic_areas where tdwg_geo_item_id is not null);
    # delete from t20140306 where id in (select gadm_geo_item_id from geographic_areas where gadm_geo_item_id is not null);
    # delete from t20140306 where id in (select geographic_item_id from georeferences where geographic_item_id is not null);

    # delete from geographic_items where id in (select id from t20140306);

    # drop table t20140306;

    GeographicItem.connection.exec('create table t20140306(id int)')
    GeographicItem.connection.exec('insert into t20140306 select id from geographic_items')

    GeographicItem.connection.exec('delete from t20140306 where id in (select ne_geo_item_id from geographic_areas where ne_geo_item_id is not null)')
    GeographicItem.connection.exec('delete from t20140306 where id in (select tdwg_geo_item_id from geographic_areas where tdwg_geo_item_id is not null)')
    GeographicItem.connection.exec('delete from t20140306 where id in (select gadm_geo_item_id from geographic_areas where gadm_geo_item_id is not null)')
    GeographicItem.connection.exec('delete from t20140306 where id in (select geographic_item_id from georeferences where geographic_item_id is not null)')

    GeographicItem.connection.exec('delete from geographic_items where id in (select id from t20140306)')
    GeographicItem.connection.exec('drop table t20140306')

  end

  def geo_object
    return false if self.new_record?
    DATA_TYPES.each do |t|
      return self.send(t) if !self.send(t).nil?
    end
    false
  end

  def contains?(item)
    self.geo_object.contains?(item.geo_object)
  end

  def within?(item)
    self.geo_object.within?(item.geo_object)
  end

  def distance?(item)
    self.geo_object.distance?(item)
  end

  def near(item, distance)
    self.geo_object.buffer(distance).contains?(item.geo_object)
  end

  def far(item, distance)
    !self.near(item, distance)
  end

  def data_type?
    DATA_TYPES.each { |item| return item if !self.send(item).nil? }
  end

  # Return the geo_object as a set of points with object type as key like:
  # {
  #  points:  [],
  #  lines:   [],
  #  polygons: []
  #  }

  def rendering_hash
    data = {}
    if self.geo_object
      case self.data_type?
        when :point
          data = point_to_hash(self.point)
        when :line_string
          data = line_string_to_hash(self.line_string)
        when :polygon
          data = polygon_to_hash(self.polygon)
        when :multi_point
          data = multi_point_to_hash(self.multi_point)
        when :multi_line_string
          data = multi_line_string_to_hash(self.multi_line_string)
        when :multi_polygon
          data = multi_polygon_to_hash(self.multi_polygon)
        when :geometry_collection
          data = self.geometry_collection_to_hash(self.geometry_collection)
        else
          # do nothing
      end
    end

    data.delete_if { |key, value| value == [] } # remove any keys with empty arrays
    data
  end

  def to_geo_json
    RGeo::GeoJSON.encode(self.geo_object).to_json
  end

  def to_a
    # get our object and return the set of points as an array
    we_are = self.geo_object

    if we_are
      data = []
      case self.data_type?
        when :point
          data = point_to_a(self.point)
        when :line_string
          data = line_string_to_a(self.line_string)
        when :polygon
          data = polygon_to_a(self.polygon)
        when :multi_point
          data = multi_point_to_a(self.multi_point)
        when :multi_line_string
          data = multi_line_string_to_a(self.multi_line_string)
        when :multi_polygon
          data = multi_polygon_to_a(self.multi_polygon)
        #when :geometry_collection
        #  data = geometry_collection_to_a(self.geometry_collection)
        else
          # do nothing
      end
      data
    else
      []
    end
  end

  protected

  def point_to_a(point)
    data = []
    data.push(point.x, point.y)
    data
  end

  def point_to_hash(point)
    {points: [point_to_a(point)]}
  end

  def line_string_to_a(line_string)
    data = []
    line_string.points.each { |point|
      data.push([point.x, point.y]) }
    data
  end

  def line_string_to_hash(line_string)
    {lines: [line_string_to_a(line_string)]}
  end

  def polygon_to_a(polygon)
    # todo: handle other parts of the polygon; i.e., the interior_rings (if they exist)
    data = []
    polygon.exterior_ring.points.each { |point|
      data.push([point.x, point.y]) }
    data
  end

  def polygon_to_hash(polygon)
    {polygons: [polygon_to_a(polygon)]}
  end

  def multi_point_to_a(multi_point)
    data = []
    multi_point.each { |point|
      data.push([point.x, point.y]) }
    data
  end

  def multi_point_to_hash(multi_point)
    # when we encounter a multi_point type, we only stick the points into the array, NOT the
    # it's identity as a group
    {points: self.to_a}
  end

  def multi_line_string_to_a(multi_line_string)
    data = []
    multi_line_string.each { |line_string|
      line_data = []
      line_string.points.each { |point|
        line_data.push([point.x, point.y]) }
      data.push(line_data)
    }
    data
  end

  def multi_line_string_to_hash(multi_line_string)
    {lines: self.to_a}
  end

  def multi_polygon_to_a(multi_polygon)
    data = []
    multi_polygon.each { |polygon|
      polygon_data = []
      polygon.exterior_ring.points.each { |point|
        polygon_data.push([point.x, point.y]) }
      data.push(polygon_data)
    }
    data
  end

  def multi_polygon_to_hash(multi_polygon)
    {polygons: self.to_a}
  end

  def geometry_collection_to_hash(geometry_collection)
    # start by constructing the general case
    # TODO: this method does *not* use the object_to_hash method, expect for the recursive geometry_collection.
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
          # TODO: would it really be better to use object_to_hash here?  Structure-wise, perhaps, but it really is faster to do it here directly, I think...
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
          # GEOMETRYCOLLECTION (LINESTRING (-32.0 21.0 0.0, -25.0 21.0 0.0, -25.0 16.0 0.0, -21.0 20.0 0.0), POLYGON ((-14.0 23.0 0.0, -14.0 11.0 0.0, -2.0 11.0 0.0, -2.0 23.0 0.0, -8.0 21.0 0.0, -14.0 23.0 0.0), (-11.0 18.0 0.0, -8.0 17.0 0.0, -6.0 20.0 0.0, -4.0 16.0 0.0, -7.0 13.0 0.0, -11.0 14.0 0.0, -11.0 18.0 0.0)), MULTILINESTRING ((23.0 21.0 0.0, 16.0 21.0 0.0, 16.0 16.0 0.0, 11.0 20.0 0.0), (4.0 12.6 0.0, 16.0 12.6 0.0, 16.0 7.6 0.0), (21.0 12.6 0.0, 26.0 12.6 0.0, 22.0 17.6 0.0)), LINESTRING (-33.0 11.0 0.0, -24.0 4.0 0.0, -26.0 13.0 0.0, -31.0 4.0 0.0, -33.0 11.0 0.0), GEOMETRYCOLLECTION (POLYGON ((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0)), POLYGON ((5.0 -1.0 0.0, -14.0 -1.0 0.0, -14.0 6.0 0.0, 5.0 6.0 0.0, 5.0 -1.0 0.0)), POLYGON ((-11.0 -1.0 0.0, -11.0 -5.0 0.0, -7.0 -5.0 0.0, -7.0 -1.0 0.0, -11.0 -1.0 0.0)), POLYGON ((-3.0 -9.0 0.0, -3.0 -1.0 0.0, -7.0 -1.0 0.0, -7.0 -9.0 0.0, -3.0 -9.0 0.0)), POLYGON ((-7.0 -9.0 0.0, -7.0 -5.0 0.0, -11.0 -5.0 0.0, -11.0 -9.0 0.0, -7.0 -9.0 0.0))), MULTILINESTRING ((-20.0 -1.0 0.0, -26.0 -6.0 0.0), (-21.0 -4.0 0.0, -31.0 -4.0 0.0)), MULTIPOLYGON (((28.0 2.3 0.0, 23.0 -1.7 0.0, 26.0 -4.8 0.0, 28.0 2.3 0.0)), ((22.0 -6.8 0.0, 22.0 -9.8 0.0, 16.0 -6.8 0.0, 22.0 -6.8 0.0)), ((16.0 2.3 0.0, 14.0 -2.8 0.0, 18.0 -2.8 0.0, 16.0 2.3 0.0))), MULTIPOINT ((3.0 -14.0 0.0), (6.0 -12.9 0.0), (5.0 -16.0 0.0), (4.0 -17.9 0.0), (7.0 -17.9 0.0)), LINESTRING (27.0 -14.0 0.0, 18.0 -21.0 0.0, 20.0 -12.0 0.0, 25.0 -23.0 0.0), GEOMETRYCOLLECTION (MULTIPOLYGON (((28.0 2.3 0.0, 23.0 -1.7 0.0, 26.0 -4.8 0.0, 28.0 2.3 0.0)), ((22.0 -6.8 0.0, 22.0 -9.8 0.0, 16.0 -6.8 0.0, 22.0 -6.8 0.0)), ((16.0 2.3 0.0, 14.0 -2.8 0.0, 18.0 -2.8 0.0, 16.0 2.3 0.0))), MULTIPOINT ((3.0 -14.0 0.0), (6.0 -12.9 0.0), (5.0 -16.0 0.0), (4.0 -17.9 0.0), (7.0 -17.9 0.0)), LINESTRING (27.0 -14.0 0.0, 18.0 -21.0 0.0, 20.0 -12.0 0.0, 25.0 -23.0 0.0)), POLYGON ((-33.0 -11.0 0.0, -33.0 -23.0 0.0, -21.0 -23.0 0.0, -21.0 -11.0 0.0, -27.0 -13.0 0.0, -33.0 -11.0 0.0)), LINESTRING (-16.0 -15.5 0.0, -22.0 -20.5 0.0), MULTIPOINT ((-88.241421 40.091565 757.0), (-88.241417 40.09161 757.0), (-88.241413 40.091655 757.0)), POINT (0.0 0.0 0.0), POINT (-29.0 -16.0 0.0), POINT (-25.0 -18.0 0.0), POINT (-28.0 -21.0 0.0), POINT (-19.0 -18.0 0.0), POINT (3.0 -14.0 0.0), POINT (6.0 -12.9 0.0), POINT (5.0 -16.0 0.0), POINT (4.0 -17.9 0.0), POINT (7.0 -17.9 0.0), POINT (32.2 22.0 0.0), POINT (-17.0 7.0 0.0), POINT (-9.8 5.0 0.0), POINT (-10.7 0.0 0.0), POINT (-30.0 21.0 0.0), POINT (-25.0 18.3 0.0), POINT (-23.0 18.0 0.0), POINT (-19.6 -13.0 0.0), POINT (-7.6 14.2 0.0), POINT (-4.6 11.9 0.0), POINT (-8.0 -4.0 0.0), POINT (-4.0 -3.0 0.0), POINT (-10.0 -6.0 0.0))
          collection_hash = geometry_collection_to_hash(it)
          collection_hash.each_key { |key|
            collection_hash[key].each { |item|
              data[key].push(item) }
            #case key
            #  when :points
            #    collection_hash[:points].each { |point|
            #      data[:points].push(point)
            #    }
            #  when :lines
            #    collection_hash[:lines].each { |line|
            #      data[:lines].push(line)
            #    }
            #  when :polygons
            #    collection_hash[:polygons].each { |polygon|
            #      data[:polygons].push(polygon)
            #    }
            #  else
            #  leave everything as it is
            #end
          }
        else
          # leave everything as it is...
      end
    }
    # remove any keys with empty arrays
    data.delete_if { |key, value| value == [] }
    data
  end

  def proper_data_is_provided
    data = []
    DATA_TYPES.each do |item|
      data.push(item) if !self.send(item).blank?
    end

    errors.add(:point, 'Must contain at least one of [point, line_string, etc.].') if data.count == 0
    if data.length > 1
      data.each do |object|
        errors.add(object, 'Only one of [point, line_string, etc.] can be provided.')
      end
    end
    true
  end
end
