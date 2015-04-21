# A georeference is an assertion that some shape, as derived from some method, describes the location of some collecting event.
# A georeference contains three components:
#    1) A reference to a CollectingEvent (who, where, when, how)
#    2) A reference to a GeographicItem (a shape)
#    3) A method by which the shape was associated with the collecting event (via `type` subclassing).
# If a georeference was published it's Source can be provided.  This is not equivalent to a method.
#
# Contains information about a location on the face of the Earth, consisting of:
#
# @!attribute geographic_item_id
#   @return [Integer]
#     The id of a GeographicItem which represents the (non-error) representation of this georeference definition.
#     Generally, it will represent a point.
# @!attribute collecting_event_id
#   @return [Integer]
#     The id of a CollectingEvent which represents the event of this georeference definition.
# @!attribute error_radius
#   @return [Integer]
#     the radius of the area of horizontal uncertainty of the accuracy of the location of
#     this georeference definition. Measured in meters. Corresponding error areas are draw from the st_centroid() of the geographic item.
# @!attribute error_depth
#   @return [Integer]
#     The distance in meters of the radius of the area of vertical uncertainty of the accuracy of the location of
#     this georeference definition.
# @!attribute error_geographic_item_id
#   @return [Integer]
#     The id of a GeographicItem which represents the (error) representation of this georeference definition.
#     Generally, it will represent a polygon.
# @!attribute type
#   @return [String]
#     The type name of the this georeference definition.
# @!attribute source_id
#   @return [Integer]
#     When provided, asserts that this data originated in the specified source.
# @!attribute position
#   @return [Integer]
#     An arbitrary ordering mechanism, the first georeference is routinely defaulted to in the application
# @!attribute is_public
#   @return [Boolean]
#     True if this georeference can be shared, otherwise false.
# @!attribute api_request
#   @return [String]
#     The text of the GeoLocation request (::GeoLocate), or the verbatim data (VerbatimData)
# @!attribute is_undefined_z
#   @return [Boolean]
#     True if this georeference cannot be located vertically, otherwise false.
# @!attribute is_median_z
#   @return [Boolean]
#     True if this georeference represents an average vertical distance, otherwise false.
#
class Georeference < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  attr_accessor :iframe_response # used to pass the geolocate from Tulane through

  acts_as_list scope: [:collecting_event]

  belongs_to :error_geographic_item, class_name: 'GeographicItem', foreign_key: :error_geographic_item_id
  belongs_to :collecting_event
  belongs_to :geographic_item
  belongs_to :source

  validates :geographic_item, presence: true
  validates :collecting_event, presence: true
  validates :type, presence: true

  validates_presence_of :geographic_item

  # validate :proper_data_is_provided
  validate :add_error_radius
  validate :add_error_depth
  validate :add_obj_inside_err_geo_item
  validate :add_obj_inside_err_radius
  validate :add_err_geo_item_inside_err_radius
  validate :add_error_radius_inside_area
  validate :add_error_geo_item_inside_area
  validate :add_obj_inside_area

  validate :geographic_item_present_if_error_radius_provided

  accepts_nested_attributes_for :geographic_item, :error_geographic_item

  # @param [GeographicItem, Double]
  # @return [Scope] Georeferences
  #   all Georeferences within some distance of a geographic_item
  def self.within_radius_of(geographic_item, distance)
    #.where{geographic_item_id in GeographicItem.within_radius_of('polygon', geographic_item, distance)}
    # geographic_item may be a polygon, or a point

    # TODO: Add different types of GeographicItems as we learn about why they are stored.
    # types of GeographicItems about which we currently know:
    # multipolygon  => stored through the NE/TDWG/GADM object load process
    # polygon       => stored through the GeoLocate process
    # point         => stored through the GeoLocate process
    #
    # TODO: or this with AREL
    temp = GeographicItem.within_radius_of('multi_polygon', geographic_item, distance) +
      GeographicItem.within_radius_of('polygon', geographic_item, distance) +
      GeographicItem.within_radius_of('point', geographic_item, distance)

    partials = GeographicItem.where('id in (?)', temp.map(&:id))

    # the use of 'pluck(:id)' here, instead of 'map(&:id)' is because pluck instantiates just the ids,
    # and not the entire record, the way map does. pluck is only available on ActiveRecord::Relation
    # and related objects.
    Georeference.where('geographic_item_id in (?)', partials.pluck(:id))
  end

  # @return [String, nil]
  #   the underscored version of the type, e.g. Georeference::GoogleMap => 'google_map'
  def method_name
    return nil if type.blank?
    type.demodulize.underscore
  end

  # @param [String] locality string
  # @return [Scope] Georeferences
  #   all Georeferences which are attached to a CollectingEvent which has a verbatim_locality which
  # includes String somewhere
  # Joins collecting_event.rb and matches %String% against verbatim_locality
  # .where(id in CollectingEvent.where{verbatim_locality like "%var%"})
  def self.with_locality_like(string)
    with_locality_as(string, true)
  end

  # @param [String] locality string
  # @return [Scope] Georeferences
  # return all Georeferences which are attached to a CollectingEvent which has a verbatim_locality which
  # equals String somewhere
  # Joins collecting_event.rb and matches %String% against verbatim_locality
  # .where(id in CollectingEvent.where{verbatim_locality like "%var%"})
  def self.with_locality(string)
    with_locality_as(string, false)
  end

  # @param [GeographicArea]
  # @return [Scope] Georeferences
  # returns all georeferences which have collecting_events which have geographic_areas which match
  # geographic_areas as a GeographicArea
  # TODO: or, (in the future) a string matching a geographic_area.name
  def self.with_geographic_area(geographic_area)
    partials   = CollectingEvent.where(geographic_area: geographic_area)
    partial_gr = Georeference.where('collecting_event_id in (?)', partials.pluck(:id))
    partial_gr
  end

  # @return [GeographicItem]
  #   a square which represents either the bounding box of the
  #   circle represented by the error_radius, or the bounding box of the error_geographic_item
  #   !! We assume the radius calculation is always larger (TODO: do we?  discuss with Jim)
  # TODO: cleanup, subclass, and calculate with SQL?
  def error_box
    retval = nil

    if error_radius.nil?
      if !error_geographic_item.nil?
        retval = error_geographic_item.dup
      end
    else
      if !geographic_item.nil? && geographic_item.geo_object_type
        case geographic_item.geo_object_type
          when :point
            # TODO: discuss, I don't think we want to imply shape for these calculateions
            retval = Utilities::Geo.point_keystone_error_box(geographic_item.geo_object, self.error_radius) #  geographic_item.keystone_error_box # error_radius_buffer_polygon #
          when :polygon
            retval = geographic_item.geo_object
          else
            retval = nil
        end
      end
      retval
    end
  end

  # GeographicItem.connection.select_all("select st_dwithin((select point from geographic_items where id = 34820), (select polygon from geographic_items where id = 34809), 6800)").first['st_dwithin']

  # @return [Rgeo::polygon, nil]
  #   a polygon representing the buffer
  def error_radius_buffer_polygon
    return nil if self.error_radius.nil? || self.geographic_item.nil?
    value = GeographicItem.connection.select_all(
      "SELECT ST_BUFFER('#{self.geographic_item.geo_object}', #{self.error_radius});").first['st_buffer']
    Gis::FACTORY.parse_wkb(value)
  end

  # Called by Gis::GeoJSON.feature_collection
  # @return [Hash] formed as a GeoJSON 'Feature'
  def to_geo_json_feature
    geometry = RGeo::GeoJSON.encode(self.geographic_item.geo_object)
    retval   = {
      'type'       => 'Feature',
      'geometry'   => geometry,
      'properties' => {'georeference' => {'id' => self.id}}
    }
    retval
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  # todo: not yet sure what the params are going to look like. what is below just represents a guess
  # @param [Hash] params from _collecting_event_selection form
  def self.batch_create_from_georeference_matcher(params)
    gr     = Georeference.find(params['georeference_id'])
    retval = 0
    params['collecting_events'].each do |event_id|
      new_gr                     = gr.dup
      new_gr.collecting_event_id = event_id
      new_gr.save
      retval += 1
    end
    retval
  end

  protected

  # @param [String, Boolean] String to find in collecting_event.verbatim_locality, Bool = false for 'Starts with',
  # Bool = true if 'contains'
  # @return [Scope] Georeferences which are attached to a CollectingEvent which has a verbatim_locality which
  #   includes, or is equal to 'string' somewhere
  # Joins collecting_event.rb and matches %String% against verbatim_locality
  # .where(id in CollectingEvent.where{verbatim_locality like "%var%"})
  # TODO: Arelize
  def self.with_locality_as(string, like)
    likeness = like ? '%' : ''
    like     = like ? 'like' : '='
    query    = "verbatim_locality #{like} '#{likeness}#{string}#{likeness}'"

    partial_ce = CollectingEvent.where(query)

    partial_gr = Georeference.where('collecting_event_id in (?)', partial_ce.pluck(:id))
    partial_gr
  end

  # @return [Boolean]
  #   true if geographic_item is completely contained in error_geographic_item
  def check_obj_inside_err_geo_item
    # case 1
    retval = true
    unless geographic_item.nil? || !geographic_item.geo_object
      unless error_geographic_item.nil?
        if error_geographic_item.geo_object # is NOT false
          retval = self.error_geographic_item.contains?(self.geographic_item.geo_object)
        end
      end
    end
    retval
  end

  # @return [Boolean]
  #   true if geographic_item is completely contained in error_box
  def check_obj_inside_err_radius
    # case 2
    retval = true
    if !error_radius.blank? && geographic_item && geographic_item.geo_object
      retval = self.error_box.contains?(self.geographic_item.geo_object)
    end
    retval
  end

  # @return [Boolean] true if error_geographic_item is completely contained in error_box
  def check_err_geo_item_inside_err_radius
    # case 3
    retval = true
    unless error_radius.nil?
      unless error_geographic_item.nil?
        if error_geographic_item.geo_object # is NOT false
          retval = self.error_box.contains?(error_geographic_item.geo_object)
        end
      end
    end
    retval
  end

  # @return [Boolean] true if error_box is completely contained in
  # collecting_event.geographic_area.default_geographic_item
  def check_error_radius_inside_area
    # case 4
    retval = true
    if collecting_event
      ga_gi = collecting_event.geographic_area_default_geographic_item
      eb    = self.error_box
      if !error_radius.blank? && ga_gi && eb
        retval = ga_gi.contains?(eb)
      end
    end
    retval
  end

  # @return [Boolean] true if error_geographic_item.geo_object is completely contained in
  # collecting_event.geographic_area.default_geographic_item
  def check_error_geo_item_inside_area
    # case 5
    retval = true
    unless collecting_event.nil?
      unless error_geographic_item.nil?
        if error_geographic_item.geo_object # is NOT false
          unless collecting_event.geographic_area.nil?
            retval = collecting_event.geographic_area.default_geographic_item.contains?(error_geographic_item.geo_object)
          end
        end
      end
    end
    retval
  end

  # @return [Boolean] true if geographic_item.geo_object is completely contained in collecting_event.geographic_area.default_geographic_item
  def check_obj_inside_area
    # case 6
    retval = true
    unless collecting_event.nil?
      unless collecting_event.geographic_area.nil? || !geographic_item.geo_object
        retval = collecting_event.geographic_area.default_geographic_item.contains?(geographic_item.geo_object)
      end
    end
    retval
  end

  # # @return [Boolean] true if error_box is completely contained in
  # # collecting_event.geographic_area.default_geographic_item
  # def check_error_radius_inside_area
  #   # case 4
  #   retval = true
  #   if collecting_event
  #     eb = self.error_box
  #     gi = collecting_event.default_area_geographic_item
  #     if eb && gi
  #       retval = gi.contains?(eb)
  #     end
  #   end
  #   retval
  # end

  # @return [Boolean] true iff collecting_event contains georeference geographic_item.
  def add_obj_inside_area
    unless check_obj_inside_area
      errors.add(:geographic_item, 'for georeference is not contained in the geographic area bound to the collecting event')
      errors.add(:collecting_event, 'is assigned to a geographic area outside the supplied georeference/geographic item')
    end
  end

  # @return [Boolean] true iff collecting_event area contains georeference error_geographic_item.
  def add_error_geo_item_inside_area
    unless check_error_geo_item_inside_area
      problem = 'collecting_event area must contain georeference error_geographic_item.'
      errors.add(:error_geographic_item, problem)
      errors.add(:collecting_event, problem)
    end
  end

  # @return [Boolean] true iff collecting_event area contains georeference error_radius bounding box.
  def add_error_radius_inside_area
    unless check_error_radius_inside_area
      problem = 'collecting_event area must contain georeference error_radius bounding box.'
      errors.add(:error_radius, problem)
      errors.add(:collecting_event, problem) # probably don't need error here
    end
  end

  # @return [Boolean] true iff error_radius contains error_geographic_item.
  def add_err_geo_item_inside_err_radius
    unless check_err_geo_item_inside_err_radius
      problem = 'error_radius must contain error_geographic_item.'
      errors.add(:error_radius, problem)
      errors.add(:error_geographic_item, problem)
    end
  end

  # @return [Boolean] true iff error_radius contains geographic_item.
  def add_obj_inside_err_radius
    if !check_obj_inside_err_radius
      errors.add(:error_radius, 'must contain geographic_item.')
    end
  end

  # @return [Boolean] true iff error_geographic_item contains geographic_item.
  def add_obj_inside_err_geo_item
    if !check_obj_inside_err_geo_item
      errors.add(:error_geographic_item, 'must contain geographic_item.')
    end
  end

  # @return [Boolean] true iff error_depth is less than 8.8 kilometers (5.5 miles).
  def add_error_depth
    if error_depth && error_depth > 8800
      errors.add(:error_depth, 'error_depth must be less than 8.8 kilometers (5.5 miles).')
    end # 8,800 meters
  end

  # @return [Boolean] true iff error_radius is less than 20,000 kilometers (12,400 miles).
  def add_error_radius
    if error_radius && error_radius > 20000000
      errors.add(:error_radius, ' must be less than 20,000 kilometers (12,400 miles).')
    end # 20,000 km
  end

  def geographic_item_present_if_error_radius_provided
    if !self.error_radius.blank? &&
      self.geographic_item_id.blank? && # provide existing
      self.geographic_item.blank? # provide new
      errors.add(:error_radius, 'can only be provided when geographic item is provided')
    end
  end

  # @param [Double, Double, Double, Double] two latitude/longitude pairs in decimal degrees
  #   find the heading between them.
  # @return [Double] Heading is returned as an angle in degrees clockwise from North.
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
