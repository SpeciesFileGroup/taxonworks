class GeographicItem < ActiveRecord::Base

  belongs_to :georeference

  # Where would one put such code?
  # RGeo::Geos.preferred_native_interface = :ffi
  # RGeo::ActiveRecord::GeometryMixin.set_json_generator(:geojson)

  DATA_TYPES = [:point,
                :line_string,
                :polygon,
                :multi_point,
                :multi_line_string,
                :multi_polygon,
                :geometry_collection]

  column_factory = RGeo::Geos.factory(
      native_interface: :ffi,
      srid:             4326,
      has_z_coordinate: true,
      has_m_coordinate: false)
  DATA_TYPES.each do |t|
    set_rgeo_factory_for_column(t, column_factory)
  end

  belongs_to :geographic_area
  belongs_to :confidence

  validate :proper_data_is_provided

  def object
    return false if self.new_record?
    DATA_TYPES.each do |t|
      return self.send(t) if !self.send(t).nil?
    end
  end

  def contains?(item)
    #item.object.within?(self.object)
    self.object.contains?(item.object)
    #true
  end

  def within?(item)
    #self.object.contains?(item.object)
    self.object.within?(item.object)
  end

  def distance?(item)
    self.object.distance?(item)
  end

  def near(item, distance)
    self.object.buffer(distance).contains?(item.object)
  end

  def far(item, distance)
    !self.near(item, distance)
  end

  def data_type?
    # what data type am I?
    DATA_TYPES.each { |item|
      return item if !self.send(item).nil? }
  end

  def render_hash
    # get our object and return the set of points as a hash with object type as key
    we_are = self.object

    if we_are
      data = {}
      case self.data_type?
        when :point
          data = {points: [self.to_a]}
        when :line_string
          data = {lines: [self.to_a]}
        when :polygon
          data = {polygons: [self.to_a]}
        when :multi_point
          data = {points: self.to_a}
        when :multi_line_string
          data = {lines: self.to_a}
        when :multi_polygon
          data = {polygons: self.to_a}
        when :geometry_collection
          data = self.geometry_collection_to_hash(self.geometry_collection)
      end
      data
    else
      {}
    end
  end

  def to_a
    # get our object and return the set of points as an array
    we_are = self.object

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

  def line_string_to_a(line_string)
    data = []
    line_string.points.each { |point|
      data.push([point.x, point.y]) }
    data
  end

  def polygon_to_a(polygon)
    # todo: handle other parts of the polygon; i.e., the interior_rings (if they exist)
    data = []
    polygon.exterior_ring.points.each { |point|
      data.push([point.x, point.y]) }
    data
  end

  def multi_point_to_a(multi_point)
    data = []
    multi_point.each { |point|
      data.push([point.x, point.y]) }
    data
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

  def geometry_collection_to_hash(geometry_collection)
    # start by constructing the general case
    data = {
        points:  [],
        lines:   [],
        polygons: []
    }
    geometry_collection.each { |it|
      case it.geometry_type.type_name
        when 'Point'
          data[:points].push([it.x, it.y])
          data
        when 'MultiPoint'
          # MULTIPOINT ((3.0 -14.0 0.0), (6.0 -12.9 0.0)
          it.each { |point|
            data[:points].push([point.x, point.y])
          }
          data
        when /^Line[S]*/ #when 'Line' or 'LineString'
          line_string_data = []
          it.points.each { |point|
            line_string_data.push([point.x, point.y]) }
          data[:lines].push(line_string_data)
          data
        when 'MultiLineString'
          # MULTILINESTRING ((-20.0 -1.0 0.0, -26.0 -6.0 0.0), (-21.0 -4.0 0.0, -31.0 -4.0 0.0))
          it.each { |line_string|
            line_string_data = []
            line_string.points.each { |point|
              line_string_data.push([point.x, point.y]) }
            data[:lines].push(line_string_data)
          }
          data
        when 'Polygon'
          # POLYGON ((-14.0 23.0 0.0, -14.0 11.0 0.0, -2.0 11.0 0.0, -2.0 23.0 0.0, -8.0 21.0 0.0, -14.0 23.0 0.0), (-11.0 18.0 0.0, -8.0 17.0 0.0, -6.0 20.0 0.0, -4.0 16.0 0.0, -7.0 13.0 0.0, -11.0 14.0 0.0, -11.0 18.0 0.0))
          # note: only the exterior_ring is processed
          polygon_data = []
          it.exterior_ring.points.each { |point|
            polygon_data.push([point.x, point.y]) }
          data[:polygons].push(polygon_data)
          data
        when 'MultiPolygon'
          # MULTIPOLYGON (((28.0 2.3 0.0, 23.0 -1.7 0.0, 26.0 -4.8 0.0, 28.0 2.3 0.0))
        when 'GeometryCollection'
          # GEOMETRYCOLLECTION (POLYGON ((-19.0 9.0 0.0, -9.0 9.0 0.0, -9.0 2.0 0.0, -19.0 2.0 0.0, -19.0 9.0 0.0)), POLYGON ((5.0 -1.0 0.0, -14.0 -1.0 0.0, -14.0 6.0 0.0, 5.0 6.0 0.0, 5.0 -1.0 0.0)), POLYGON ((-11.0 -1.0 0.0, -11.0 -5.0 0.0, -7.0 -5.0 0.0, -7.0 -1.0 0.0, -11.0 -1.0 0.0)), POLYGON ((-3.0 -9.0 0.0, -3.0 -1.0 0.0, -7.0 -1.0 0.0, -7.0 -9.0 0.0, -3.0 -9.0 0.0)), POLYGON ((-7.0 -9.0 0.0, -7.0 -5.0 0.0, -11.0 -5.0 0.0, -11.0 -9.0 0.0, -7.0 -9.0 0.0)))
        else
          # ignore it for now
      end
    }
    data.delete_if{|key, value| value == []}
    data
  end

  def proper_data_is_provided
    data = []
    DATA_TYPES.each do |item|
      data.push(item) if !self.send(item).blank?
    end

    case
      when data.length == 0
        errors.add(:point, 'Must contain at least one of [point, line_string, etc.].')
      when data.length > 1
        data.each do |object|
          errors.add(object, 'Only one of [point, line_string, etc.] can be provided.')
        end
      else
        true
    end
  end
end
