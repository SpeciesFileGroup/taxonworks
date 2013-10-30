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

=begin
    if we_are
      {self.data_type? => self.to_a}
    else
      {}
    end
=end
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
          data.push(self.point.x, point.y)
        when :line_string
          self.line_string.points.each { |point|
            data.push([point.x, point.y]) }
        when :polygon
          self.polygon.exterior_ring.points.each { |point|
            data.push([point.x, point.y]) }
        when :multi_point
          self.multi_point.each { |point|
            data.push([point.x, point.y]) }
        when :multi_line_string
          self.multi_line_string.each { |line_string|
            line_data = []
            line_string.points.each { |point|
              line_data.push([point.x, point.y]) }
            data.push(line_data)
          }
        when :multi_polygon
          self.multi_polygon.each { |polygon|
            polygon_data = []
            polygon.exterior_ring.points.each { |point|
              polygon_data.push([point.x, point.y]) }
            data.push(polygon_data)
          }
      end
      data
    else
      []
    end
  end

  protected

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
