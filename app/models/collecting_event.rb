# A collecting event is the unique combination of who, where, when, and how.
# 
# @!attribute field_notes 
#   @return [String]
#   Any/all field notes that this collecting event was derived from, or that supplement this collecting event.
# @!attribute verbatim_label 
#   @return [String]
#   A verbatim representation of label that defined this collecting event, typically, but not exclusively, 
#   used for retroactive data capture.
# @!attribute print_label 
#   @return [String]
#   A print-formatted ready representation of this collecting event.  !! Do not assume that this remains static,
#   it can change over time with user needs.
# @!attribute document_label 
#   @return [String]
#   A print-ready expanded/clarified version of a verbatim_label intended to clarify interpretation of that label.
#   To be used, for example, when reporting Holotype labels.
# @!attribute verbatim_locality
#   @return [String]
#     a string, typically sliced from verbatim_label, that represents the locality, including any modifiers (2 mi NE).
# @!attribute verbatim_date
#   @return [String]
#     a string typically sliced from verbatim_label, that represents the collective date. Is not calculated on. Same as http://rs.tdwg.org/dwc/terms/verbatimEventDate.
# @!attribute verbatim_longitude
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents the longitude. Is used to derive mappable values, but does not get mapped itself
# @!attribute verbatim_latitude
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents the latitude. Is used to derive mappable values, but does not get mapped itself. 
# @!attribute verbatim_geolocation_uncertainty
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents the provided uncertainty value.
# @!attribute verbatim_elevation
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents all elevation data (min/max/precision) as recorded there.
# @!attribute minimum_elevation
#   @return [String]
#   A float, in meters.
# @!attribute maximum_elevation
#   @return [String]
#   A float, in meters.
# @!attribute elevation_precision
#   @return [String]
#   A float, in meters.
# @!attribute time_start_hour 
#   @return [integer]
#     0-23
# @!attribute time_start_minute
#   @return [integer]
#     0-59
# @!attribute time_start_seconds
#   @return [integer]
#     0-59 
# @!attribute time_end_hour 
#   @return [integer]
#     0-23
# @!attribute time_end_minute
#   @return [integer]
#     0-59
# @!attribute time_end_seconds
#   @return [integer]
#     0-59 
class CollectingEvent < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::DataAttributes
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include SoftValidation

  has_paper_trail

  belongs_to :geographic_area, inverse_of: :collecting_events

  has_many :collection_objects, inverse_of: :collecting_event, dependent: :restrict_with_error
  has_many :collector_roles, class_name: 'Collector', as: :role_object, dependent: :destroy
  has_many :collectors, through: :collector_roles, source: :person
  has_many :error_geographic_items, through: :georeferences, source: :error_geographic_item
  has_many :geographic_items, through: :georeferences # See also all_geographic_items, the union
  has_many :georeferences, dependent: :destroy
  has_one :accession_provider_role, class_name: 'AccessionProvider', as: :role_object, dependent: :destroy
  has_one :deaccession_recipient_role, class_name: 'DeaccessionRecipient', as: :role_object, dependent: :destroy

  # Todo: this needs work
  has_one :verbatim_georeference, class_name: 'Georeference::VerbatimData'

  before_validation :check_verbatim_geolocation_uncertainty,
                    :check_date_range,
                    :check_elevation_range
  before_save :set_cached
  before_save :set_times_to_nil_if_form_provided_blank

  validates_uniqueness_of :md5_of_verbatim_label, scope: [:project_id], unless: 'verbatim_label.blank?'
  validates_presence_of :verbatim_longitude, if: '!verbatim_latitude.blank?'
  validates_presence_of :verbatim_latitude, if: '!verbatim_longitude.blank?'
  validates :geographic_area, presence: true, allow_nil: true

  validates :time_start_hour,
            allow_nil:    true,
            numericality: {
              only_integer: true,
              in:           (0..23),
              message:      'start time hour must be 0-23'
            }

  validates :time_start_minute,
            allow_nil:    true,
            numericality: {
              only_integer: true,
              in:           (0..59),
              message:      'start time minute must be 0-59'
            }

  validates :time_start_second,
            allow_nil:    true,
            numericality: {
              only_integer: true,
              in:           (0..59),
              message:      'start time second must be 0-59'
            }

  validates_presence_of :time_start_minute, if: '!self.time_start_second.blank?'
  validates_presence_of :time_start_hour, if: '!self.time_start_minute.blank?'


  validates :time_end_hour,
            allow_nil:    true,
            numericality: {
              only_integer: true,
              in:           (0..23),
              message:      'end time hour must be 0-23'}

  validates :time_end_minute,
            allow_nil:    true,
            numericality: {
              only_integer: true,
              in:           (0..59),
              message:      'end time minute must be 0-59'}

  validates :time_end_second,
            allow_nil:    true,
            numericality: {
              only_integer: true,
              in:           (0..59),
              message:      'end time second must be 0-59'}

  validates_presence_of :time_end_minute, if: '!self.time_end_second.blank?'
  validates_presence_of :time_end_hour, if: '!self.time_end_minute.blank?'


  # TODO: factor these out (see also TaxonDetermination, Source::Bibtex)
  validates :start_date_year,
            numericality: {only_integer: true,
                           greater_than: 1000,
                           less_than:    (Time.now.year + 5),
                           message:      'start date year must be an integer greater than 1500, and no more than 5 years in the future'},
            length:       {is: 4},
            allow_nil:    true

  validates :end_date_year,
            numericality: {only_integer: true,
                           greater_than: 1000,
                           less_than:    (Time.now.year + 5),
                           message:      'end date year must be an integer greater than 1500, and no more than 5 years int he future'},
            length:       {is: 4},
            allow_nil:    true

  # TODO: combine validations
  validates_inclusion_of :start_date_month,
                         in:     Utilities::Dates::LEGAL_MONTHS,
                         unless: 'start_date_month.blank?'

  validates_inclusion_of :end_date_month,
                         in:     Utilities::Dates::LEGAL_MONTHS,
                         unless: 'end_date_month.blank?'

  validates_presence_of :start_date_month,
                        if: '!start_date_day.nil?'

  validates_presence_of :end_date_month,
                        if: '!end_date_day.nil?'

  validates_numericality_of :end_date_day,
                            allow_nil:             true,
                            only_integer:          true,
                            greater_than:          0,
                            less_than_or_equal_to: Proc.new { |a| Time.utc(a.end_date_year, a.end_date_month).end_of_month.day },
                            unless:                'end_date_year.nil? || end_date_month.nil?',
                            message:               '%{value} is not a valid end_date_day for the month provided'

  validates_numericality_of :start_date_day,
                            allow_nil:             true,
                            only_integer:          true,
                            greater_than:          0,
                            less_than_or_equal_to: Proc.new { |a| Time.utc(a.start_date_year, a.start_date_month).end_of_month.day },
                            unless:                'start_date_year.nil? || start_date_month.nil?',
                            message:               '%{value} is not a valid start_date_day for the month provided'

  soft_validate(:sv_minimally_check_for_a_label)

  NEARBY_DISTANCE = 5000

  # @param [String]
  def verbatim_label=(value)
    write_attribute(:verbatim_label, value)
    write_attribute(:md5_of_verbatim_label, Utilities::Strings.generate_md5(value))
  end

  # @return [Boolean]
  def has_start_date?
    !start_date_day.blank? && !start_date_month.blank? && !start_date_year.blank?
  end

  # @return [Boolean]
  def has_end_date?
    !end_date_day.blank? && !end_date_month.blank? && !end_date_year.blank?
  end

  # @return [Utilities::Dates]
  def end_date
    Utilities::Dates.nomenclature_date(end_date_day, end_date_month, end_date_year)
  end

  # @return [Utilities::Dates]
  def start_date
    Utilities::Dates.nomenclature_date(start_date_day, start_date_month, start_date_year)
  end

  # @return [String]
  #   like 00, 00:00, or 00:00:00
  def time_start
    Utilities::Dates.format_to_hours_minutes_seconds(time_start_hour, time_start_minute, time_start_second)
  end

  # @return [String]
  #   like 00, 00:00, or 00:00:00
  def time_end
    Utilities::Dates.format_to_hours_minutes_seconds(time_end_hour, time_end_minute, time_end_second)
  end

  def generate_verbatim_georeference
    # TODOone @mjy Write some version of a translator from other forms of Lat/Long to decimal degrees, otherwise failure
    # will occur here
    if self.verbatim_latitude && self.verbatim_longitude && !self.new_record?
      local_latitude  = self.verbatim_latitude
      local_longitude = self.verbatim_longitude
      local_latitude  = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(local_latitude)
      local_longitude = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(local_longitude)
      point           = Georeference::FACTORY.point(local_latitude, local_longitude)
      g               = GeographicItem.new(point: point)
      r               = get_error_radius
      if g.valid?
        g.save
        update(verbatim_georeference: Georeference::VerbatimData.create(geographic_item: g, error_radius: r))
      end
    end
  end

  # @return [Integer]
  def get_error_radius
    return nil if verbatim_geolocation_uncertainty.blank?
    return verbatim_geolocation_uncertainty.to_i if is.number?(verbatim_geolocation_uncertainty)
    nil
    # TODO: figure out how to convert verbatim_geolocation_uncertainty in different units (ft, m, km, mi) into meters
  end

  # TODO: 'figure out what it actually means' (@mjy) 20140718
  # @return [Scope] geographic_items associated with this collecting_event
  def all_geographic_items
    event   = nil
    results = GeographicItem.
      joins('LEFT JOIN georeferences g2 ON geographic_items.id = g2.error_geographic_item_id').
      joins('LEFT JOIN georeferences g1 ON geographic_items.id = g1.geographic_item_id').
      where(['(g1.collecting_event_id = ? OR g2.collecting_event_id = ?) AND (g1.geographic_item_id IS NOT NULL OR g2.error_geographic_item_id IS NOT NULL)', self.id, self.id])
    if event.nil?
      return results
    end
  end

  # @param [GeographicItem]
  # @return [String]
  # see how far away we are from another gi
  def distance_to(geographic_item)
    # retval = GeographicItem.ordered_by_shortest_distance_from('any', geographic_items.first).limit(1).first
    retval = self.geographic_items.first.st_distance(geographic_item.geo_object)
    return(retval)
  end

  # @param [Double] distance
  # @return [Scope]
  def find_others_within_radius_of(distance)
    # starting with self, find all (other) CEs which have GIs or EGIs (through georeferences) which are within a
    # specific distance (in meters)
    gi     = geographic_items.first
    pieces = GeographicItem.joins(:georeferences).within_radius_of('any', gi, distance)

    ce = []
    pieces.each { |o|
      ce.push(o.collecting_events_through_georeferences.to_a)
      ce.push(o.collecting_events_through_georeference_error_geographic_item.to_a)
    }
    pieces = CollectingEvent.where('id in (?)', ce.flatten.map(&:id).uniq)

    pieces.excluding(self)
  end

  # @return [Scope]
  # Find all (other) CEs which have GIs or EGIs (through georeferences) which intersect self
  def find_others_intersecting_with
    pieces = GeographicItem.with_collecting_event_through_georeferences.intersecting('any', self.geographic_items.first).uniq
    gr     = [] # all collecting events for a geographic_item

    pieces.each { |o|
      gr.push(o.collecting_events_through_georeferences.to_a)
      gr.push(o.collecting_events_through_georeference_error_geographic_item.to_a)
    }

    # todo: change 'id in (?)' to some other sql construct
    pieces = CollectingEvent.where(id: gr.flatten.map(&:id).uniq)
    pieces.excluding(self)
  end

  # @return [Scope]
  # Find other CEs that have GRs whose GIs or EGIs are contained in the EGI
  def find_others_contained_in_error
    # find all the GIs and EGIs associated with CEs
    pieces = GeographicItem.with_collecting_event_through_georeferences.to_a

    me = self.error_geographic_items.first.geo_object
    gi = []
    # collect all the GIs which are within the EGI
    pieces.each { |o|
      gi.push(o) if o.geo_object.within?(me)
    }
    # collect all the CEs which refer to these GIs
    ce = []
    gi.each { |o|
      ce.push(o.collecting_events_through_georeferences.to_a)
      ce.push(o.collecting_events_through_georeference_error_geographic_item.to_a)
    }

    # TODO: Directly map this
    pieces = CollectingEvent.where(id: ce.flatten.map(&:id).uniq)
    pieces.excluding(self)
  end

  # @param [String, String, Integer]
  # @return [Scope]
  def nearest_by_levenshtein(compared_string = nil, column = 'verbatim_locality', limit = 10)
    return CollectingEvent.none if compared_string.nil?
    order_str = CollectingEvent.send(:sanitize_sql_for_conditions, ["levenshtein(collecting_events.#{column}, ?)", compared_string])
    CollectingEvent.where('id <> ?', self.to_param).
      order(order_str).
      limit(limit)
  end


  # returns either:
  #  ( {'name' => [GAs]} 
  # or 
  # [{'name' => [GAs]}, {'name' => [GAs]}]) 
  #   one hash, consisting of a country name paired with an array of the corresponding GAs, or
  #   an array of all of the hashes (name/GA pairs),
  #   which are country_level, and have GIs containing the (GI and/or EGI) of this CE
  # @param [String]
  # @return [Hash]
  def name_hash(types)
    retval  = {} # changed from []
    gi_list = []

    if self.georeferences.count == 0
      # use geographic_area only if there are no GIs or EGIs
      unless self.geographic_area.nil?
        # we need to use the geographic_area directly
        gi_list << GeographicItem.are_contained_in('any', self.geographic_area.geographic_items)
      end
    else
      # gather all the GIs which contain this GI or EGI
      gi_list << GeographicItem.are_contained_in('any', self.geographic_items.to_a + self.error_geographic_items.to_a)
    end

    # there are a few ways we can end up with no GIs
    unless gi_list.count == 0
      # map the resulting GIs to their corresponding GAs
      pieces  = GeographicItem.where(id: gi_list.flatten.map(&:id).uniq)
      ga_list = GeographicArea.includes(:geographic_area_type, :geographic_areas_geographic_items).
        where(geographic_area_types:             {name: types},
              geographic_areas_geographic_items: {geographic_item_id: pieces}).uniq

      # WAS: now find all of the GAs which have the same names as the ones we collected.

      # map the names to an array of results
      ga_list.each { |i|
        retval[i.name] ||= [] # if we haven't come across this name yet, set it to point to a blank array
        retval[i.name].push i # we now have at least a blank array, push the result into it
      }
    end
    retval
  end

  # @return [Hash]
  def countries_hash
    name_hash(GeographicAreaType::COUNTRY_LEVEL_TYPES)
  end

  # returns either:   ( {'name' => [GAs]} or [{'name' => [GAs]}, {'name' => [GAs]}])
  #   one hash, consisting of a state name paired with an array of the corresponding GAs, or
  #   an array of all of the hashes (name/GA pairs),
  #   which are state_level, and have GIs containing the (GI and/or EGI) of this CE
  # @return [Hash]
  def states_hash
    name_hash(GeographicAreaType::STATE_LEVEL_TYPES)
  end

  # returns either:   ( {'name' => [GAs]} or [{'name' => [GAs]}, {'name' => [GAs]}])
  #   one hash, consisting of a county name paired with an array of the corresponding GAs, or
  #   an array of all of the hashes (name/GA pairs),
  #   which are county_level, and have GIs containing the (GI and/or EGI) of this CE
  # @return [Hash]
  def counties_hash
    name_hash(GeographicAreaType::COUNTY_LEVEL_TYPES)
  end

  # @param [Hash]
  # @return [String]
  def name_from_geopolitical_hash(name_hash)
    return name_hash.keys.first if name_hash.keys.count == 1
    most_key   = nil
    most_count = 0
    name_hash.keys.sort.each do |k| # alphabetically first (keys are unordered)
      if name_hash[k].size > most_count
        most_count = name_hash[k].size
        most_key   = k
      end
    end
    most_key
  end

  # @return [String]
  def country_name
    name_from_geopolitical_hash(countries_hash)
  end

  # @return [String]
  def state_or_province_name
    name_from_geopolitical_hash(states_hash)
  end

  # @return [String]
  def state_name
    state_or_province_name
  end

  # @return [String]
  def county_or_equivalent_name
    name_from_geopolitical_hash(counties_hash)
  end

  # @return [String]
  def county_name
    county_or_equivalent_name
  end

=begin
TODO: @mjy: please fill in any other paths you can think of for the acquisition of information for the seven below listed items
  ce.georeference.geographic_item.centroid
  ce.georeference.error_geographic_item.centroid
  ce.verbatim_georeference
  ce.verbatim_lat/ee.verbatim_lng
  ce.verbatim_locality
  ce.geographic_area.geographic_item.centroid

  There are a number of items we can try to get data for to complete the geolocate parameter string:

  'country' can come from:
    GeographicArea through ce.country_name

  'state' can come from:
    GeographicArea through ce.state_or_province_name

  'county' can come from:
    GeographicArea through ce.county_or_equivalent_name

  'locality' can come from:
    ce.verbatim_locality

  'Latitude', 'Longitude' can come from:
    GeographicItem through ce.georeferences.geographic_item.centroid
    GeographicItem through ce.georeferences.error_geographic_item.centroid
    GeographicArea through ce.geographic_area.geographic_area_map_focus

  'Placename' can come from:
    ? Copy of 'locality'
=end

  # @return [Hash]
  def geolocate_ui_params_hash
    parameters = {}

    parameters[:country]   = country_name
    parameters[:state]     = state_or_province_name
    parameters[:county]    = county_or_equivalent_name
    parameters[:locality]  = verbatim_locality
    parameters[:Placename] = verbatim_locality

    focus = nil
    # in reverse order of precedence
    unless geographic_area.nil?
      focus = geographic_area.geographic_area_map_focus
    end
    unless georeferences.count == 0
      unless georeferences.first.error_geographic_item.nil?
        # expecting error_geographic_item to be a polygon or multi_polygon
        focus = georeferences.first.error_geographic_item.st_centroid
      end
      unless georeferences.first.geographic_item.nil?
        # the georeferences.first.geographic_item for a verbatim_data instance is a point
        focus = georeferences.first.geographic_item
      end
    end

    unless focus.nil?
      parameters[:Longitude] = focus.point.x
      parameters[:Latitude]  = focus.point.y
    end
    @geolocate_request = Georeference::GeoLocate::RequestUI.new(parameters)
    @geolocate_string  = @geolocate_request.request_params_string
    @geolocate_hash    = @geolocate_request.request_params_hash
  end

  # @return [String]
  def geolocate_ui_params_string
    if @geolocate_hash.nil?
      geolocate_ui_params_hash
    end
    @geolocate_string
  end

  # @return [GeoJSON::Feature]
  def to_geo_json_feature
    # geometry = RGeo::GeoJSON.encode(self.georeferences.first.geographic_item.geo_object)
    geo_item = self.georeferences.first.geographic_item
    geometry = JSON.parse(GeographicItem.connection.select_all("select ST_AsGeoJSON(#{geo_item.geo_object_type.to_s}::geometry) geo_json from geographic_items where id=#{geo_item.id};")[0]['geo_json'])
    retval   = {
      'type'       => 'Feature',
      'geometry'   => geometry,
      'properties' => {
        'collecting_event' => {
          'id' => self.id}
      }
    }
    retval
  end

  # class methods

  # @param geographic_item [GeographicItem]
  # @return [Scope]
  def self.find_others_contained_within(geographic_item)
    pieces = GeographicItem.joins(:georeferences).is_contained_by('any', geographic_item)
    # pieces = GeographicItem.is_contained_by('any', geographic_item)
    pieces

    ce = []
    pieces.each { |o|
      ce.push(o.collecting_events_through_georeferences.to_a)
      ce.push(o.collecting_events_through_georeference_error_geographic_item.to_a)
    }
    pieces = CollectingEvent.where('id in (?)', ce.flatten.map(&:id).uniq)

    pieces.excluding(self)

  end

  # @param collecting_events [CollectingEvent Scope]
  # @return [Scope] without self (if included)
  def self.excluding(collecting_events)
    where.not(id: collecting_events)
  end

  # Rich-  add a comment indicating why this is here if you want this to persist for a temporary period of time).
  def self.test
    result = []
    colors = ["black", "brown", "red", "orange", "yellow", "green", "blue", "purple", "gray", "white"]
    names  = ["Zerothus nillus", "Firstus, specius", "Secondus duo", "thirdius trio", "Fourthus quattro", "Fithus ovwhiskius", "Sixtus sextus", "Seventhus septium", "Eighthus octo", "Ninethus novim", "Tenthus dix"]
    self.all.each_with_index do |c, i|
      result.push(RGeo::GeoJSON.encode(c.georeferences.first.geographic_item.geo_object).merge('descriptor' => {'color' => colors[i], 'name' => names[i]}))
    end
    'var data = ' + result.to_json + ';'
  end

  # @param params [Hash] of parameters for this search
  # @return [Scope] of collecting_events found by (partial) verbatim_locality
  def self.find_for_autocomplete(params)
    Queries::CollectingEventAutocompleteQuery.new(params[:term]).all
  end

  # @param [Scope]
  # @return [CSV]
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

  protected

  def set_cached
    string = nil 

    if verbatim_label.blank?
      string = [country_name, state_name, county_name, "\n", verbatim_locality, start_date, end_date, "\n", verbatim_collectors].compact.join
    else
      string = [verbatim_label, print_label, document_label].compact.first 
    end

    string = "[#{self.id.to_param}]" if string.strip.length == 0
    self.cached = string 
  end

  def set_times_to_nil_if_form_provided_blank
    matches         = ['0001-01-01 00:00:00 UTC', '2000-01-01 00:00:00 UTC']
    self.time_start = nil if matches.include?(self.time_start.to_s)
    self.time_end   = nil if matches.include?(self.time_end.to_s)
  end

  def check_verbatim_geolocation_uncertainty
    errors.add(:verbatim_geolocation_uncertainty, 'Provide both verbatim_latitude and verbatim_longitude if you provide verbatim_uncertainty.') if !verbatim_geolocation_uncertainty.blank? && verbatim_longitude.blank? && verbatim_latitude.blank?
  end

  def check_date_range
    errors.add(:base, 'End date is earlier than start date.') if has_start_date? && has_end_date? && (start_date > end_date)
  end

  def check_elevation_range
    errors.add(:maximum_elevation, 'Maximum elevation is lower than minimum elevation.') if !minimum_elevation.blank? && !maximum_elevation.blank? && maximum_elevation < minimum_elevation
  end

  def sv_minimally_check_for_a_label
    [:verbatim_label, :print_label, :document_label, :field_notes].each do |v|
      return true if !self.send(v).blank?
    end
    soft_validations.add(:base, 'At least one label type, or field notes, should be provided.')
  end

end
