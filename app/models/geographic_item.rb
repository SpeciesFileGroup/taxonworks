class GeographicItem < ActiveRecord::Base

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
                                     srid: 4326,
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
