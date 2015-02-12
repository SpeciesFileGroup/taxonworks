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
#   A string, typically sliced from verbatim_label, that represents the locality, including any modifiers (2 mi NE).
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
#
#
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
                    :check_elevation_range,
                    :build_cached

  validates_uniqueness_of :md5_of_verbatim_label, scope: [:project_id], unless: 'verbatim_label.blank?'
  validates_presence_of :verbatim_longitude, if: '!verbatim_latitude.blank?'
  validates_presence_of :verbatim_latitude, if: '!verbatim_longitude.blank?'
  validates :geographic_area, presence: true, allow_nil: true

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

  def verbatim_label=(value)
    write_attribute(:verbatim_label, value)
    write_attribute(:md5_of_verbatim_label, Utilities::Strings.generate_md5(value))
  end

  def has_start_date?
    !start_date_day.blank? && !start_date_month.blank? && !start_date_year.blank?
  end

  def has_end_date?
    !end_date_day.blank? && !end_date_month.blank? && !end_date_year.blank?
  end

  def end_date
    Utilities::Dates.nomenclature_date(end_date_day, end_date_month, end_date_year)
  end

  def start_date
    Utilities::Dates.nomenclature_date(start_date_day, start_date_month, start_date_year)
  end

  def generate_verbatim_georeference
    # TODO @mjy Write some version of a translator from other forms of Lat/Long to decimal degrees, otherwise failure
    # will occur here
    if verbatim_latitude && verbatim_longitude && !new_record?
      point = Georeference::FACTORY.point(verbatim_latitude, verbatim_longitude)
      g     = GeographicItem.new(point: point)
      r     = get_error_radius
      if g.valid?
        g.save
        update(verbatim_georeference: Georeference::VerbatimData.create(geographic_item: g, error_radius: r))
      end
    end
  end

  def get_error_radius
    return nil if verbatim_geolocation_uncertainty.blank?
    return verbatim_geolocation_uncertainty.to_i if is.number?(verbatim_geolocation_uncertainty)
    nil
    # TODO: figure out how to convert verbatim_geolocation_uncertainty in different units (ft, m, km, mi) into meters
  end

  # TODO: 'figure out what it actually means' (@mjy) 20140718
  def all_geographic_items
    GeographicItem.select('g1.* FROM geographic_items gi').
      join('LEFT JOIN georeferences g1 ON gi.id = g1.geographic_item_id').
      join('LEFT JOIN georeferences g2 ON g2.id = g2.error_geographic_item_id').
      where(['(g1.collecting_event_id = id OR g2.collecting_event_id = id) AND (g1.geographic_item_id IS NOT NULL OR g2.error_geographic_item_id IS NOT NULL)', id, id])
  end

  # see how far away we are from another gi
  def distance_to(geographic_item)
    # retval = GeographicItem.ordered_by_shortest_distance_from('any', geographic_items.first).limit(1).first
    retval = self.geographic_items.first.st_distance(geographic_item.geo_object)
    return(retval)
  end

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

  def countries_hash
    name_hash(GeographicAreaType::COUNTRY_LEVEL_TYPES)
  end

  # returns either:   ( {'name' => [GAs]} or [{'name' => [GAs]}, {'name' => [GAs]}])
  #   one hash, consisting of a state name paired with an array of the corresponding GAs, or
  #   an array of all of the hashes (name/GA pairs),
  #   which are state_level, and have GIs containing the (GI and/or EGI) of this CE
  def states_hash
    name_hash(GeographicAreaType::STATE_LEVEL_TYPES)
  end

  # returns either:   ( {'name' => [GAs]} or [{'name' => [GAs]}, {'name' => [GAs]}])
  #   one hash, consisting of a county name paired with an array of the corresponding GAs, or
  #   an array of all of the hashes (name/GA pairs),
  #   which are county_level, and have GIs containing the (GI and/or EGI) of this CE
  def counties_hash
    name_hash(GeographicAreaType::COUNTY_LEVEL_TYPES)
  end

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

  def country_name
    name_from_geopolitical_hash(countries_hash)
  end

  def state_or_province_name
    name_from_geopolitical_hash(states_hash)
  end

  def state_name
    state_or_province_name
  end

  def county_or_equivalent_name
    name_from_geopolitical_hash(counties_hash)
  end

  def county_name
    county_or_equivalent_name
  end

=begin
TODO: @mjy: please fill in any other paths you cqan think of for the acquisition of information for the seven below listed items
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

  def geolocate_ui_params_string
    if @geolocate_hash.nil?
      geolocate_ui_params_hash
    end
    @geolocate_string
  end

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

  def self.find_for_autocomplete(params)
    where('verbatim_locality LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
    # changed from 'cached' to 'verbatim_locality':
  end

  def self.generate_download(scope, project_id)
    CSV.generate do |csv|
      csv << column_names
      scope.with_project_id(project_id).order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  protected

  # TODO: Draper Candidate
  # A *stub*
  def build_cached
    if verbatim_label.blank?
      cached = [country_name, state_name, county_name, "\n", verbatim_locality, start_date, end_date, verbatim_collectors, "\n"].compact.join
    else
      cached = verbatim_label
    end
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
