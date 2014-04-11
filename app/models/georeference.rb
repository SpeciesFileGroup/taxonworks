# Contains information about a location on the face of the Earth, consisting of:
#
# @!attribute geographic_item_id
#   @return [Integer]
#    the id of a GeographicItem that represents the (non-error) representation of this georeference definition
# @!attribute collecting_event_id
#   @return [Integer]
#    the id of a CollectingEvent that represents the event of this georeference definition
# @!attribute error_radius
#   @return [Integer]
#    the distance in meters of the radius of the area of horizontal uncertainty of the accuracy of the location of this georeference definition
# @!attribute error_depth
#   @return [Integer]
#    the distance in meters of the radius of the area of vertical uncertainty of the accuracy of the location of this georeference definition
# @!attribute error_geographic_item_id
#   @return [Integer]
#    the id of a GeographicItem that represents the (error) representation of this georeference definition
# @!attribute type
#   @return [String]
#    the type name of the this georeference definition
# @!attribute source_id
#   @return [Integer]
#    the id of the source of this georeference definition
# @!attribute position
#   @return [Integer]
#    the position of this georeference definition
# @!attribute request
#   @return [String]
#    the text of the GeoLocation request (::GeoLocate), or the verbatim data (VerbatimData)
class Georeference < ActiveRecord::Base
  include Housekeeping

#  https://groups.google.com/forum/#!topic/rgeo-users/lMCr0mOt1F0
# TODone: Some of the GADM polygons seem to violate shapefile spec for *some* reason (not necessarily those stated in the above group post). As a possible remedy, adding ":uses_lenient_multi_polygon_assertions => true"
# TODone: This is also supposed to be the default factory (in fact, the *only* factory), but that does not seem to be the case. See lib/tasks/build_geographic_areas.rake

  FACTORY = RGeo::Geographic.projected_factory(srid:                    4326,
                                               projection_srid:         4326,
                                               projection_proj4:        '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs',
                                               uses_lenient_assertions: true,
                                               has_z_coordinate:        true)
=begin
  FACTORY = ::RGeo::Geos.factory(native_interface:                      :ffi,
                                 uses_lenient_multi_polygon_assertions: true,
                                 srid:                                  4326,
                                 has_z_coordinate:                      true)
=end


  # this represents a GeographicItem, but has a name (error_geographic_item) which is *not* the name of the column used in the table;
  # therefore, we need to tell it *which* table, and what to use to address the record we want
  belongs_to :error_geographic_item, class_name: 'GeographicItem', foreign_key: :error_geographic_item_id

  belongs_to :collecting_event
  belongs_to :geographic_item

  accepts_nested_attributes_for :geographic_item, :error_geographic_item

  validate :proper_data_is_provided
  validates :geographic_item, presence: true
  validates :collecting_event, presence: true
  validates :type, presence: true

  def error_box?
    # start with a copy of the point of the reference
    #retval = geographic_item.dup

    # returns a square which represents either the bounding box of the
    # circle represented by the error_radius, or the bounding box of the error_geographic_item, whichever is greater
    if error_radius.nil?
      # use the bounding box of the error_geo_item
      if error_geographic_item.nil?
        retval = nil
      else
        retval = error_geographic_item.dup
        #retval = error_geographic_item
      end
    else
      if geographic_item.nil?
        retval = nil
      else
        # if this object is a point
        case geographic_item.data_type?
          when :point
            p0      = self.geographic_item.geo_object
            delta_x = (error_radius / ONE_WEST) / ::Math.cos(p0.y)  # 111319.490779206 meters/degree
            delta_y = error_radius / ONE_NORTH  # 110574.38855796 meters/degree
            # make a diamond 2 * radius tall and 2 * radius wide, with the reference point as center
            retval  = FACTORY.polygon(FACTORY.line_string([FACTORY.point(p0.x, p0.y + delta_y), # north
                                                           FACTORY.point(p0.x + delta_x, p0.y), # east
                                                           FACTORY.point(p0.x, p0.y - delta_y), # south
                                                           FACTORY.point(p0.x - delta_x, p0.y)  # west
                                                          ]))
            box = RGeo::Cartesian::BoundingBox.new(FACTORY)
            box.add(retval)
            box_geom = box.to_geometry

            # or
            # make the rectangle directly
            retval  = FACTORY.polygon(FACTORY.line_string([FACTORY.point(p0.x - delta_x, p0.y + delta_y), # northwest
                                                           FACTORY.point(p0.x + delta_x, p0.y + delta_y), # northeast
                                                           FACTORY.point(p0.x + delta_x, p0.y - delta_y), # southeast
                                                           FACTORY.point(p0.x - delta_x, p0.y - delta_y)  # southwest
                                                          ]))
          when :polygon
            retval = geographic_item
          else
            retval = nil
        end
        #retval = retval.to_geometry
      end
    end
    retval
  end

  protected

  def chk_obj_inside_err_geo_item
    # case 1
    retval = true
    if error_geographic_item.nil? == false && geographic_item.nil? == false
      retval = self.error_geographic_item.contains?(self.geographic_item)
    end
    retval
  end

  def chk_obj_inside_err_radius
    # case 2
    retval = true
    if error_radius.nil? == false && geographic_item.nil? == false
      retval = self.error_box?.contains?(self.geographic_item.geo_object)
    end
    retval
  end

  def chk_err_geo_item_inside_err_radius
    # case 3
    retval = true
    if error_radius.nil? == false && error_geographic_item.nil? == false
      retval = self.error_box?.contains?(error_geographic_item.geo_object)
    end
    retval
  end

  def chk_error_radius_inside_area
    # case 4
    retval = true
    unless collecting_event.nil?
      if error_radius.nil? == false && collecting_event.geographic_area.nil? == false
        retval = collecting_event.geographic_area.geo_object.contains?(error_box?)
      end
    end
    retval
  end

  def chk_error_geo_item_inside_area
    # case 5
    retval = true
    unless collecting_event.nil?
      if error_geographic_item.nil? == false && collecting_event.geographic_area.nil? == false
        retval = collecting_event.geographic_area.default_geographic_item.contains?(error_geographic_item)
      end
    end
    retval
  end

  def chk_obj_inside_area
    # case 6
    retval = true
    unless collecting_event.nil?
      unless collecting_event.geographic_area.nil?
        retval = collecting_event.geographic_area.geo_object.contains?(geographic_item.geo_object)
      end
    end
    retval
  end

  def proper_data_is_provided
    retval = true
    #case
    #when GeographicItem.find(geographic_item_id) == nil
    #  errors.add(:geographic_item, 'ID must be from item of class Geographic_Item.') # THis isn't necessary, we'll have an index on the db
    #when CollectingEvent.find(collecting_event_id) == nil
    #  errors.add(:collecting_event, 'ID must be from item of class CollectingEvent.')
    #when GeographicItem.find(error_geographic_item_id).geo_object.geometry_type.type_name != 'Polygon'
    #  errors.add(:geographic_item, 'ID must be from item of class Geographic_Item of type \'POLYGON\'.')
    #when GeoreferenceHash[*arr]
    #  Type.find(type).to_s != 'Georeference::GeoreferenceType'
    #  errors.add(:georeference, 'type must be of class Georeference::GeoreferenceType.')
    #else
    #true
    #end
    unless error_radius.nil?
      errors.add(:error_radius, 'error_radius must be less than 20,000 kilometers (12,400 miles).') if error_radius > 20000000 # 20,000 km
      retval = false
    end
    unless error_depth.nil?
      errors.add(:error_depth, 'error_depth must be less than 8,800 kilometers (5.5 miles).') if error_depth > 8800 # 8,800 meters
      retval = false
    end
    #unless error_geographic_item.nil?
    #  errors.add(:error_geographic_item, 'error_geographic_item must contain geographic_item.') unless error_geographic_item.geo_object.contains?(geographic_item.geo_object)
    #end
    unless chk_obj_inside_err_geo_item
      errors.add(:error_geographic_item, 'error_geographic_item must contain geographic_item.')
      retval = false
    end
    unless chk_obj_inside_err_radius
      errors.add(:error_radius, 'error_radius must contain geographic_item.')
      retval = false
    end
    unless chk_err_geo_item_inside_err_radius
      problem = 'error_radius must contain error_geographic_item.'
      errors.add(:error_radius, problem)
      errors.add(:error_geographic_item, problem)
      retval = false
    end
    unless chk_error_radius_inside_area
      problem = 'collecting_event area must contain error_radius bounding box.'
      errors.add(:error_radius, problem)
      errors.add(:collecting_event, problem)
      retval = false
    end
    unless chk_error_geo_item_inside_area
      problem = 'collecting_event area must contain error_geographic_item.'
      errors.add(:error_geographic_item, problem)
      errors.add(:collecting_event, problem)
      retval = false
    end
    unless chk_obj_inside_area
      problem = 'collecting_event area must contain geographic_item.'
      errors.add(:geographic_item, problem)
      errors.add(:collecting_event, problem)
      retval = false
    end

    retval
  end

  POINT_ONE_DIAGONAL = 15690.343288662 # 15690.343288662
  ONE_WEST           = 111319.490779206
  ONE_NORTH          = 110574.38855796
  TEN_WEST           = 1113194.90779206
  TEN_NORTH          = 1105854.83323573

  EARTH_RADIUS       = 6371000 # km, 3959 miles (mean Earth radius)
  RADIANS_PER_DEGREE = ::Math::PI/180.0
  DEGREES_PER_RADIAN = 180.0/::Math::PI

  # Given two latitude/longitude pairs in degrees, find the heading between them.
  # Heading is returned as an angle in degrees clockwise from north.

  def heading(from_lat_, from_lon_, to_lat_, to_lon_)
    from_lat_rad_  = RADIANS_PER_DEGREE * from_lat_
    to_lat_rad_    = RADIANS_PER_DEGREE * to_lat_
    delta_lon_rad_ = RADIANS_PER_DEGREE * (to_lon_ - from_lon_)
    y_             = ::Math.sin(delta_lon_rad_) * ::Math.cos(to_lat_rad_)
    x_             = ::Math.cos(from_lat_rad_) * ::Math.sin(to_lat_rad_) -
      ::Math.sin(from_lat_rad_) * ::Math.cos(to_lat_rad_) * ::Math.cos(delta_lon_rad_)
    DEGREES_PER_RADIAN * ::Math.atan2(y_, x_)
  end
end
