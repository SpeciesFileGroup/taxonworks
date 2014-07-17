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
#   A print-formatted ready represenatation of this collecting event.  !! Do not assume that this remains static, 
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
  include Shared::Identifiable
  include Shared::Notable
  include Shared::DataAttributes
  include SoftValidation

  belongs_to :geographic_area, inverse_of: :collecting_events

  has_many :collection_objects, inverse_of: :collecting_event, dependent: :restrict_with_error
  has_many :collector_roles, class_name: 'Collector', as: :role_object, dependent: :destroy
  has_many :collectors, through: :collector_roles, source: :person
  has_many :error_geographic_items, through: :georeferences, source: :error_geographic_item
  has_many :geographic_items, through: :georeferences # See also all_geographic_items, the union
  has_many :georeferences, dependent: :destroy

  # Todo: this needs work
  has_one :verbatim_georeference, class_name: 'Georeference::VerbatimData'

  before_validation :check_verbatim_geolocation_uncertainty,
                    :check_date_range,
                    :check_elevation_range

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
    if verbatim_latitude && verbatim_longitude && !new_record?
      point = Georeference::FACTORY.point(verbatim_latitude, verbatim_longitude)
      g     = GeographicItem.new(point: point)
      if g.valid?
        g.save
        update(verbatim_georeference: Georeference::VerbatimData.create(geographic_item: g))
      end
    end
  end

  # TODO: 'figure out what it actually means' (mjy) 20140718
  def all_geographic_items
    GeographicItem.select('g1.* FROM geographic_items gi').
      join('LEFT JOIN georeferences g1 ON gi.id = g1.geographic_item_id').
      join('LEFT JOIN georeferences g2 ON g2.id = g2.error_geographic_item_id').
      where(["(g1.collecting_event_id = id OR g2.collecting_event_id = id) AND (g1.geographic_item_id IS NOT NULL OR g2.error_geographic_item_id IS NOT NULL)", id, id])
  end

  def find_others_within_radius_of(distance)
    # starting with self, find all (other) CEs which have GIs or EGIs (through georeferences) which are within a
    # specific distance (in meters)
    gi     = geographic_items.first
    pieces = GeographicItem.within_radius_of('any', gi, distance)

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

    ## todo: change 'id in (?)' to some other sql construct
    pieces = CollectingEvent.where(id: gr.flatten.map(&:id).uniq)
    pieces.excluding(self)
  end

  # 'find other CEs that have GRs whose GIs or EGIs are contained in the EGI'
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

  # returns either:   ( {'name' => [GAs]} or [{'name' => [GAs]}, {'name' => [GAs]}])
  #   one hash, consisting of a country name paired with an array of the corresponding GAs, or
  #   an array of all of the hashes (name/GA pairs),
  #   which are country_level, and have GIs containing the (GI and/or EGI) of this CE
  def countries_hash
    retval  = []
    # ga_list = []
    gi_list = []


    # gather all the GIs which contain this GI or EGI
    gi_list << GeographicItem.containing('any', self.geographic_items).pluck(:id)
    gi_list << GeographicItem.containing('any', self.error_geographic_items).pluck(:id)

    gi_list.flatten!
    ga_list = GeographicArea.includes(:geographic_area_type, :geographic_areas_geographic_items).
      where(geographic_area_types:             {name: GeographicAreaType::COUNTRY_LEVEL_TYPES},
            geographic_areas_geographic_items: {geographic_item_id: gi_list}).uniq

    # map the resulting GIs to their corresponding GAs
    # ga_list << gi_list.uniq.flatten.map(&:geographic_areas).uniq

    # isolate those which are of the level0 GATs like 'Country'.
    # ga_list.flatten.each { |ga|
    #   GeographicAreaType::COUNTRY_LEVEL_TYPES.each { |gat_text|
    #     gat = GeographicAreaType.where(:name => gat_text).first
    #     if ga.geographic_area_type == gat
    #       retval << {ga.name => ga}
    #     end
    #   }
    # }
    # gi_list = GeographicItem.containing('any', self.geographic_items.first).to_a

    ga_list.each { |ga|
      retval << {ga.name => ga}
    }
    if retval.count < 2
      retval = retval[0]
    end
    retval
  end

  # returns either:   ( {'name' => [GAs]} or [{'name' => [GAs]}, {'name' => [GAs]}])
  #   one hash, consisting of a state name paired with an array of the corresponding GAs, or
  #   an array of all of the hashes (name/GA pairs),
  #   which are state_level, and have GIs containing the (GI and/or EGI) of this CE
  def states_hash

  end

  # returns either:   ( {'name' => [GAs]} or [{'name' => [GAs]}, {'name' => [GAs]}])
  #   one hash, consisting of a county name paired with an array of the corresponding GAs, or
  #   an array of all of the hashes (name/GA pairs),
  #   which are county_level, and have GIs containing the (GI and/or EGI) of this CE
  def counties_hash

  end

  def country_name

  end

  def state_or_province_name

  end

  def state_name
    state_or_province_name
  end

  def county_or_equivalent_name

  end

  def county_name
    county_or_equivalent_name
  end

  # class methods

  def self.excluding(collecting_events)
    where.not(id: collecting_events)
  end

  # Rich-  add a comment indicating why it's here if you want this to persist for a temporary period of time).
  def self.test
    result = []
    colors = ["black", "brown", "red", "orange", "yellow", "green", "blue", "purple", "gray", "white"]
    names  = ["Zerothus nillus", "Firstus, specius", "Secondus duo", "thirdius trio", "Fourthus quattro", "Fithus ovwhiskius", "Sixtus sextus", "Seventhus septium", "Eighthus octo", "Ninethus novim", "Tenthus dix"]
    self.all.each_with_index do |c, i|
      result.push(RGeo::GeoJSON.encode(c.georeferences.first.geographic_item.geo_object).merge('descriptor' => {'color' => colors[i], 'name' => names[i]}))
    end
    'var data = ' + result.to_json + ';'
  end

  protected

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
