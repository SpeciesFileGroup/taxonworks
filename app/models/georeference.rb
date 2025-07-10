# A Georeference is an assertion that some shape, as derived from some method, describes the location of
# some CollectingEvent.
#
# A georeference contains three components:
#  1) A reference to a CollectingEvent (who, where, when, how)
#  2) A reference to a GeographicItem (a shape)
#  3) A method by which the shape was associated with the collecting event (via `type` subclassing).
# If a georeference was published its Source can be provided.  This is not equivalent to providing a method for deriving the georeference.
#
# Contains information about a location on the face of the Earth, consisting of:
#
# @!attribute geographic_item_id
#   @return [Integer]
#   The id of a GeographicItem which represents the (non-error) representation of this georeference definition.
#   Generally, it will represent a point.
#
# @!attribute collecting_event_id
#   @return [Integer]
#   The id of a CollectingEvent which represents the event of this georeference definition.
#
# @!attribute error_radius
#   @return [Integer]
#   the radius of the area of horizontal uncertainty of the accuracy of the location of
#   this georeference definition. Measured in meters. Corresponding error areas are draw from the
# st_centroid() of the geographic item.
#
# @!attribute error_depth
#   @return [Integer]
#   The distance in meters of the radius of the area of vertical uncertainty of the accuracy of the location of
#   this georeference definition.
#
# @!attribute error_geographic_item_id
#   @return [Integer]
#   The id of a GeographicItem which represents the (error) representation of this georeference definition.
#    Generally, it will represent a polygon.
#
# @!attribute type
#   @return [String]
#   The type name of the this georeference definition.
#
# @!attribute position
#   @return [Integer]
#   An arbitrary ordering mechanism, the first georeference is routinely defaulted to in the application.
#
# @!attribute is_public
#   @return [Boolean]
#   True if this georeference can be shared, otherwise false.
#
# @!attribute api_request
#   @return [String]
#   The text of the GeoLocation request (::GeoLocate), or the verbatim data (VerbatimData).
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute year_georeferenced
#   @return [Integer, nil]
#     4 digit year the georeference was *first* created/captured
#
# @!attribute month_georeferenced
#   @return [Integer, nil]
#
# @!attribute day_georeferenced
#   @return [Integer, nil]
#
class Georeference < ApplicationRecord
  include Housekeeping
  include SoftValidation
  include Shared::Notes
  include Shared::Tags
  include Shared::ProtocolRelationships
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::Confidences # qualitative, not spatial
  include Shared::Maps # TODO: included twice
  include Shared::DwcOccurrenceHooks
  include Shared::IsData

  include Shared::Maps

  attr_accessor :iframe_response # used to handle the geolocate from Tulane response

  acts_as_list scope: [:collecting_event_id, :project_id], add_new_at: :top

  belongs_to :collecting_event, inverse_of: :georeferences
  belongs_to :error_geographic_item, class_name: 'GeographicItem', inverse_of: :georeferences_through_error_geographic_item
  belongs_to :geographic_item, inverse_of: :georeferences

  has_many :collection_objects, through: :collecting_event, inverse_of: :georeferences
  has_many :field_occurrences, through: :collecting_event, inverse_of: :georeferences

  has_many :collection_object_otus, -> { unscope(:order) }, through: :collection_objects, source: 'otu'
  has_many :field_occurrence_otus, -> { unscope(:order) }, through: :field_occurrences, source: 'otu'

  has_many :otus, through: :collection_objects, source: 'otus'

  has_many :georeferencer_roles, class_name: 'Georeferencer', as: :role_object, dependent: :destroy, inverse_of: :role_object
  has_many :georeference_authors, -> { order('roles.position ASC') }, through: :georeferencer_roles, source: :person # , inverse_of: :georeferences

  validates :year_georeferenced, date_year: {min_year: 1000, max_year: Time.now.year }
  validates :month_georeferenced, date_month: true
  validates :day_georeferenced, date_day: {year_sym: :year_georeferenced, month_sym: :month_georeferenced},
    unless: -> { year_georeferenced.nil? || month_georeferenced.nil? }

  validates :collecting_event, presence: true
  validates :collecting_event_id, uniqueness: { scope: [:type, :geographic_item_id, :project_id] }
  validates :geographic_item, presence: true
  validates :type, presence: true # TODO: technically not needed

  validate :add_err_geo_item_inside_err_radius
  validate :add_error_depth
  validate :add_error_geo_item_intersects_area
  validate :add_error_radius
  validate :add_error_radius_inside_area
  validate :add_obj_inside_area
  validate :add_obj_inside_err_geo_item
  validate :add_obj_inside_err_radius
  validate :geographic_item_present_if_error_radius_provided

  # validate :add_error_geo_item_inside_area

  accepts_nested_attributes_for :geographic_item, :error_geographic_item

  # @return [Boolean]
  #  When true, cascading cached values (e.g. in CollectingEvent) are not built
  attr_accessor :no_cached

  before_validation :round_error_radius
  before_validation :set_geographic_item, unless: -> { self.geographic_item_id.blank? }
  after_save :set_cached, unless: -> { self.no_cached || (self.collecting_event && self.collecting_event.no_cached == true) }
  after_destroy :set_cached_collecting_event



  def otus
    ::Queries.union(Otu, [collection_object_otus, field_occurrence_otus])
  end

  def self.point_type
    joins(:geographic_item)
      .where(geographic_items: {geo_object_type: :point})
  end

  # TODO: remove, used in match georeferences
  # @param [Array] of parameters in the style of 'params'
  # @return [Scope] of selected georeferences
  def self.filter_by(params)
    collecting_events = CollectingEvent.filter_by(params)

    georeferences = Georeference.where('collecting_event_id in (?)', collecting_events.ids)
    georeferences
  end

  # @param [Integer] geographic_item_id
  # @param [Integer] distance
  # @return [Scope] georeferences
  #   all georeferences within some distance of a geographic_item, by id
  def self.within_radius_of_item(geographic_item_id, distance)
    return none if geographic_item_id.nil? || distance.nil?

    Georeference.joins(:geographic_item).where(
      GeographicItem.within_radius_of_item_sql(geographic_item_id, distance)
    )
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
    partials = CollectingEvent.where(geographic_area:)
    partial_gr = Georeference.where('collecting_event_id in (?)', partials.pluck(:id))
    partial_gr
  end

  # TODO: not yet sure what the params are going to look like. what is below just represents a guess
  # @param [ActionController::Parameters] arguments from _collecting_event_selection form
  # @return [Array] of georeferences
  def self.batch_create_from_georeference_matcher(arguments)
    gr = Georeference.find(arguments[:georeference_id].to_param)

    result = []

    collecting_event_list = arguments[:checked_ids]

    unless collecting_event_list.nil?
      collecting_event_list.each do |event_id|
        new_gr = Georeference.new(
          collecting_event_id: event_id.to_i,
          geographic_item_id: gr.geographic_item_id,
          error_radius: gr.error_radius,
          error_depth: gr.error_depth,
          error_geographic_item_id: gr.error_geographic_item_id,
          type: gr.type,
          is_public: gr.is_public,
          api_request: gr.api_request)
        if new_gr.valid? # generally, this catches the case of multiple identical georeferences per collecting_event.
          new_gr.save!
          result.push new_gr
        end
      end
    end
    result
  end

  # @param [String, Boolean] String to find in collecting_event.verbatim_locality, Bool = false for 'Starts with',
  # Bool = true if 'contains'
  # @return [Scope] Georeferences which are attached to a CollectingEvent which has a verbatim_locality which
  #   includes, or is equal to 'string' somewhere
  # Joins collecting_event.rb and matches %String% against verbatim_locality
  # .where(id in CollectingEvent.where{verbatim_locality like "%var%"})
  # TODO: Arelize
  def self.with_locality_as(string, like)
    likeness = like ? '%' : ''
    query = "verbatim_locality #{like ? 'ilike' : '='} '#{likeness}#{string}#{likeness}'"

    Georeference.where(collecting_event: CollectingEvent.where(query))
  end

  def dwc_occurrences
    co = DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins('JOIN georeferences g on co.collecting_event_id = g.collecting_event_id')
      .where(g: {id:})

    fo = DwcOccurrence
      .joins("JOIN field_occurrences fo on dwc_occurrence_object_id = fo.id AND dwc_occurrence_object_type = 'FieldOccurrence'")
      .joins('JOIN georeferences g on fo.collecting_event_id = g.collecting_event_id')
      .where(g: {id:})

    ::Queries.union(DwcOccurrence, [co, fo])
  end

  # @return [Hash]
  #   The interface to DwcOccurrence writiing for Georeference based values.
  #   See subclasses for super extensions.
  def dwc_georeference_attributes(h = {})
    georeferenced_by = if georeference_authors.any?
                         georeference_authors.collect{|a| a.cached}.join('|')
                       else
                         creator.name
                       end
    h.merge!(
      footprintWKT: geographic_item.to_wkt,
      georeferenceVerificationStatus: confidences&.collect{|c| c.name}.join('; ').presence,
      georeferencedBy: georeferenced_by,
      georeferencedDate: created_at,
      georeferenceProtocol: protocols.collect{|p| p.name}.join('|')
    )

    if geographic_item.geo_object_type == :point
      h[:decimalLongitude] = geographic_item.geo_object.x
      h[:decimalLatitude] = geographic_item.geo_object.y
      h[:coordinateUncertaintyInMeters] = error_radius
    end

    h
  end

  # @return [String, nil]
  #   the underscored version of the type, e.g. Georeference::GoogleMap => 'google_map'
  def method_name
    return nil if type.blank?
    type.demodulize.underscore
  end

  # @return [GeographicItem, nil]
  #   a square which represents either the bounding box of the
  #   circle represented by the error_radius, or the bounding box of the error_geographic_item
  #   !! We assume the radius calculation is always larger (TODO: do we?  discuss with Jim)
  # TODO: cleanup, subclass, and calculate with SQL?
  def error_box
    retval = nil

    if error_radius.nil?
      retval = error_geographic_item.dup unless error_geographic_item.nil?
    else
      unless geographic_item.nil?
        if geographic_item.geo_object_type
          case geographic_item.geo_object_type
          when :point
            retval = Utilities::Geo.error_box_for_point(geographic_item.geo_object, error_radius)
          when :polygon, :multi_polygon
            retval = geographic_item.geo_object
          end
        end
      end
    end
    retval
  end

  # DEPRECATED
  # @return [Rgeo::polygon, nil]
  #   a polygon representing the buffer
  def error_radius_buffer_polygon
    return nil if error_radius.nil? || geographic_item.nil?

    sql_str = ActivRecord::Base.send(
      :sanitize_sql_array,
      ['SELECT ST_Buffer(?, ?)',
       geographic_item.geo_object.to_s,
       (error_radius / Utilities::Geo::ONE_WEST_MEAN)])
    value = GeographicItem.connection.select_all(sql_str).first['st_buffer']
    Gis::FACTORY.parse_wkb(value)
  end

  # Called by Gis::GeoJSON.feature_collection
  # @return [Hash] formed as a GeoJSON 'Feature'
  def to_geo_json_feature
    to_simple_json_feature.merge(
      'properties' => {
        'georeference' => {
          'id' => id,
          'tag' => "Georeference ID = #{id}"
        },
        'radius' => error_radius
      }
    )
  end

  # @return [String]
  def latitude
    geographic_item.center_coords[0]
  end

  # @return [String]
  def longitude
    geographic_item.center_coords[1]
  end

  # TODO: parametrize to include gazeteer
  #   i.e. geographic_areas_geogrpahic_items.where( gaz = 'some string')
  # @return [JSON Feature]
  def to_simple_json_feature
    geometry = RGeo::GeoJSON.encode(geographic_item.geo_object)
    {
      'type' => 'Feature',
      'geometry' => geometry,
      'properties' => {}
    }
  end

  # Calculate the radius from error shapes
  # !! Used to retroactively rebuild the radius from the polygon shape
  def radius_from_error_shape
    error_geographic_item&.radius
  end

  protected

  def set_cached_collecting_event
    collecting_event.send(:set_cached)
  end

  def set_cached
    collecting_event.send(:set_cached_geographic_names)
  end

  # validation methods

  # @return [Boolean]
  #   true if geographic_item is completely contained in error_geographic_item
  def check_obj_inside_err_geo_item
    # case 1
    retval = true
    unless geographic_item.nil? || !geographic_item.geo_object
      unless error_geographic_item.nil?
        if error_geographic_item.geo_object # is NOT false
          retval = error_geographic_item.contains?(geographic_item.geo_object)
        end
      end
    end
    retval
  end

  # @return [Boolean]
  #   true if geographic_item is completely contained in error_box
  # def check_obj_inside_err_radius
  #   # case 2
  #   retval = true
  #   if !error_radius.blank? && geographic_item && geographic_item.geo_object
  #     retval = error_box.contains?(geographic_item.geo_object)
  #   end
  #   retval
  # end

  # @return [Boolean]
  #   true if geographic_item is completely contained in error_box
  def check_obj_inside_err_radius
    # case 2
    retval = true
    # if !error_radius.blank? && geographic_item && geographic_item.geo_object
    if error_radius.present?
      if geographic_item.present?
        if geographic_item.geo_object.present?
          val = error_box
          if val.present?
            retval = val.contains?(geographic_item.geo_object)
          end
        end
      end
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
          retval = error_box.contains?(error_geographic_item.geo_object)
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
      eb = error_box
      if error_radius.present? # rubocop:disable Style/IfUnlessModifier
        retval = ga_gi.contains?(eb) if ga_gi && eb
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
            retval = collecting_event.geographic_area.default_geographic_item
              .contains?(error_geographic_item.geo_object)
          end
        end
      end
    end
    retval
  end

  # @return [Boolean] true if error_geographic_item.geo_object intersects (overlaps)
  # collecting_event.geographic_area.default_geographic_item
  def check_error_geo_item_intersects_area
    # case 5.5
    retval = true
    if collecting_event.present?
      if error_geographic_item.present?
        if error_geographic_item.geo_object.present?
          if collecting_event.geographic_area.present?
            # !! TODO: check fir nil case
            retval = collecting_event.geographic_area.default_geographic_item
              .intersects?(error_geographic_item.geo_object)
          end
        end
      end
    end
    retval
  end

  # @return [Boolean]
  #    true if geographic_item.geo_object is completely contained in collecting_event.geographic_area
  # .default_geographic_item
  def check_obj_inside_area
    # case 6
    retval = true
    if collecting_event.present?
      if geographic_item.present? && collecting_event.geographic_area.present?
        if geographic_item.geo_object && collecting_event.geographic_area.default_geographic_item.present?
          retval = collecting_event.geographic_area.default_geographic_item.contains?(geographic_item.geo_object)
        end
      end
    end
    retval
  end

  # @return [Boolean] true iff collecting_event contains georeference geographic_item.
  def add_obj_inside_area
    unless check_obj_inside_area
      errors.add(
        :geographic_item,
        'for georeference is not contained in the geographic area bound to the collecting event')
      errors.add(
        :collecting_event,
        'is assigned a geographic area which does not contain the supplied georeference/geographic item')
    end
  end

  # @return [Boolean] true iff collecting_event area contains georeference error_geographic_item.
  def add_error_geo_item_inside_area
    unless check_error_geo_item_inside_area
      problem = 'collecting_event geographic area must contain georeference error_geographic_item.'
      errors.add(:error_geographic_item, problem)
      errors.add(:collecting_event, problem)
    end
  end

  # @return [Boolean] true iff collecting_event area intersects georeference error_geographic_item.
  def add_error_geo_item_intersects_area
    unless check_error_geo_item_intersects_area
      problem = 'collecting_event geographic area must intersect georeference error_geographic_item.'
      errors.add(:error_geographic_item, problem)
      errors.add(:collecting_event, problem)
    end
  end

  # @return [Boolean] true iff collecting_event area contains georeference error_radius bounding box.
  def add_error_radius_inside_area
    unless check_error_radius_inside_area
      problem = 'collecting_event geographic area must contain georeference error_radius bounding box.'
      errors.add(:error_radius, problem)
      errors.add(:collecting_event, problem) # probably don't need error here
    end
  end

  # @return [Boolean] true iff error_radius contains error_geographic_item.
  def add_err_geo_item_inside_err_radius
    unless check_err_geo_item_inside_err_radius # rubocop:disable Style/GuardClause
      problem = 'error_radius must contain error_geographic_item.'
      errors.add(:error_radius, problem)
      errors.add(:error_geographic_item, problem)
    end
  end

  # @return [Boolean] true iff error_radius contains geographic_item.
  def add_obj_inside_err_radius
    errors.add(:error_radius, 'must contain geographic_item.') unless check_obj_inside_err_radius
  end

  # @return [Boolean] true iff error_geographic_item contains geographic_item.
  def add_obj_inside_err_geo_item
    errors.add(:error_geographic_item, 'must contain geographic_item.') unless check_obj_inside_err_geo_item
  end

  # @return [Boolean] true iff error_depth is less than 8.8 kilometers (5.5 miles).
  def add_error_depth
    errors.add(:error_depth, 'error_depth must be less than 8.8 kilometers (5.5 miles).') if error_depth &&
      error_depth > 8_800 # 8,800 meters
  end

  # @return [Boolean] true iff error_radius is less than 10 kilometers (6.6 miles).
  def add_error_radius
    if error_radius.present? && error_radius > 10_000 # 10 km
      errors.add(:error_radius, ' must be less than 10 kilometers (6.6 miles).')
    end
  end

  def geographic_item_present_if_error_radius_provided
    if error_radius.present? &&
        geographic_item_id.blank? && # provide existing
        geographic_item.blank? # provide new
      errors.add(:error_radius, 'can only be provided when geographic item is provided')
    end
  end

  # TODO: Should be in lib/utilities/geo.rb.
  # @param [Double] from_lat_
  # @param [Double] from_lon_
  # @param [Double] to_lat_
  # @param [Double] to_lon_
  # @return [Double] Heading is returned as an angle in degrees clockwise from North.
  def heading(from_lat_, from_lon_, to_lat_, to_lon_)
    from_lat_rad_ = RADIANS_PER_DEGREE * from_lat_
    to_lat_rad_ = RADIANS_PER_DEGREE * to_lat_
    delta_lon_rad_ = RADIANS_PER_DEGREE * (to_lon_ - from_lon_)
    y_ = ::Math.sin(delta_lon_rad_) * ::Math.cos(to_lat_rad_)
    x_ = ::Math.cos(from_lat_rad_) * ::Math.sin(to_lat_rad_) -
      ::Math.sin(from_lat_rad_) * ::Math.cos(to_lat_rad_) * ::Math.cos(delta_lon_rad_)
    DEGREES_PER_RADIAN * ::Math.atan2(y_, x_)
  end

  private

  def set_geographic_item
    self.geographic_item = GeographicItem.find(geographic_item_id)
  end

  def round_error_radius
    if error_radius.present?
      self[:error_radius] = error_radius.round
    end
  end

end

#Dir[Rails.root.to_s + '/app/models/georeference/**/*.rb'].each { |file| require_dependency file }
