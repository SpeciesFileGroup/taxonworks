# A collecting event describes how something (e.g. a CollectionObject) was aquired.  It is the unique combination of who, where, when, and how.
#
# @!attribute verbatim_label
#   @return [String]
#   A verbatim representation of label that defined this collecting event, typically, but not exclusively,
#   used for retroactive data capture.
#
# @!attribute print_label
#   @return [String]
#   A print-formatted ready representation of this collecting event.  !! Do not assume that this remains static,
#   it can change over time with user needs.
#
# @!attribute document_label
#   @return [String]
#   A print-ready expanded/clarified version of a verbatim_label intended to clarify interpretation of that label.
#   To be used, for example, when reporting Holotype labels.
#
# @!attribute verbatim_locality
#   @return [String]
#     a string, typically sliced from verbatim_label, that represents the locality, including any modifiers (2 mi NE).
#
# @!attribute verbatim_longitude
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents the longitude. Is used to derive mappable values, but does not get mapped itself
#
# @!attribute verbatim_latitude
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents the latitude. Is used to derive mappable values, but does not get mapped itself.
#
# @!attribute verbatim_geolocation_uncertainty
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents the provided uncertainty value.
#
# @!attribute verbatim_trip_identifier
#   @return [String]
#      the literal string/identifier used by the collector(s) to identify this particular collecting event, usually part of a series particular to one trip
#
# @!attribute verbatim_collectors
#   @return [String]
#     the literal string that indicates the collectors, typically taken right off the label
#
# @!attribute verbatim_method
#   @return [String]
#     the literal string that indicates the collecting method, typically taken right off the label
#
# @!attribute geographic_area_id
#   @return [Integer]
#     the finest geo-political unit that this collecting event can be localized to, can be used for gross georeferencing when Georeference not available
#
# @!attribute minimum_elevation
#   @return [String]
#   A float, in meters.
#
# @!attribute maximum_elevation
#   @return [String]
#   A float, in meters.
#
# @!attribute elevation_precision
#   @return [String]
#   A float, in meters.
#
# @!attribute field_notes
#   @return [String]
#   Any/all field notes that this collecting event was derived from, or that supplement this collecting event.
#
# @!attribute md5_of_verbatim_label
#   @return [String]
#      application defined, an index to the verbatim label
#
# @!attribute cached
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents the provided uncertainty value.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute start_date_year
#   @return [Integer]
#    the four digit year, start of the collecting event
#
# @!attribute end_date_year
#   @return [Integer]
#    the four digit year, end of the collecting event
#
# @!attribute start_date_day
#   @return [Integer]
#     the day of the month the collecting event started on
#
# @!attribute end_date_day
#   @return [Integer]
#     the date of the month the collecting event ended on
#
# @!attribute verbatim_elevation
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents all elevation data (min/max/precision) as recorded there.
#
# @!attribute verbatim_habitat
#   @return [String]
#     a literal string, typically taken from the printed label, tha represents assertions about the habitat
#
# @!attribute verbatim_datum
#   @return [String]
#   @todo
#
# @!attribute time_start_hour
#   @return [Integer]
#     0-23
#
# @!attribute time_start_minute
#   @return [Integer]
#     0-59
#
# @!attribute time_start_second
#   @return [Integer]
#     0-59
#
# @!attribute time_end_hour
#   @return [Integer]
#     0-23
#
# @!attribute time_end_minute
#   @return [Integer]
#     0-59
#
# @!attribute time_end_second
#   @return [Integer]
#     0-59
#
# @!attribute verbatim_date
#   @return [String]
#    the string representation, typically as taken from the label, of the date
#
# @!attribute start_date_month
#   @return [Integer]
#     the month, from 0-12, that the collecting event started on
#
# @!attribute end_date_month
#   @return [Integer]
#     the month, from 0-12, that the collecting event ended on
#
# @!attribute cached_level0_geographic_name
#   @return [String, nil]
#     the auto-calculated level0 (= country in TaxonWorks) value drawn from GeographicNames, never directly user supplied
#
# @!attribute cached_level1_geographic_name
#   @return [String, nil]
#     the auto-calculated level1 (typically state/province) value drawn from GeographicNames, never directly user supplied
#
# @!attribute cached_level2_geographic_name
#   @return [String, nil]
#     the auto-calculated level2 value (e.g. county) drawn from GeographicNames, never directly user supplied
#
#
class CollectingEvent < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::DataAttributes
  include Shared::HasRoles
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::Depictions
  include Shared::IsData
  include Shared::Confidence
  include SoftValidation

  has_paper_trail

  NEARBY_DISTANCE = 5000

  attr_accessor :with_verbatim_data_georeference

  # @return [Boolean]
  #  When true, cached values are not built
  attr_accessor :no_cached

  after_create {
    if with_verbatim_data_georeference
      generate_verbatim_data_georeference(true)
    end
  }

  before_save :set_times_to_nil_if_form_provided_blank

  after_save :cache_geographic_names, if: '!self.no_cached && geographic_area_id_changed?'
  after_save :set_cached, if: '!self.no_cached'

  belongs_to :geographic_area, inverse_of: :collecting_events

  has_one :accession_provider_role, class_name: 'AccessionProvider', as: :role_object, dependent: :destroy
  has_one :deaccession_recipient_role, class_name: 'DeaccessionRecipient', as: :role_object, dependent: :destroy
  has_one :verbatim_data_georeference, class_name: 'Georeference::VerbatimData'
  has_one :preferred_georeference, -> { order(:position) }, class_name: 'Georeference', foreign_key: :collecting_event_id

  has_many :collection_objects, inverse_of: :collecting_event, dependent: :restrict_with_error
  has_many :collector_roles, class_name: 'Collector', as: :role_object, dependent: :destroy
  has_many :collectors, through: :collector_roles, source: :person
  has_many :error_geographic_items, through: :georeferences, source: :error_geographic_item
  has_many :geographic_items, through: :georeferences # See also all_geographic_items, the union
  has_many :georeferences, dependent: :destroy
  has_many :geo_locate_georeferences, class_name: 'Georeference::GeoLocate', dependent: :destroy

  accepts_nested_attributes_for :geo_locate_georeferences
  accepts_nested_attributes_for :verbatim_data_georeference
  accepts_nested_attributes_for :collectors, :collector_roles, allow_destroy: true

  validate :check_verbatim_geolocation_uncertainty,
           :check_date_range,
           :check_elevation_range

  validates_uniqueness_of :md5_of_verbatim_label, scope: [:project_id], unless: 'verbatim_label.blank?'
  validates_presence_of :verbatim_longitude, if: '!verbatim_latitude.blank?'
  validates_presence_of :verbatim_latitude, if: '!verbatim_longitude.blank?'

  validates :geographic_area, presence: true, allow_nil: true

  validates :time_start_hour,
            allow_nil:    true,
            numericality: {
              only_integer: true,
              greater_than: -1, less_than: 24,
              message:      'start time hour must be 0-23'
            }

  validates :time_start_minute,
            allow_nil:    true,
            numericality: {
              only_integer: true,
              greater_than: -1, less_than: 60,
              message:      'start time minute must be 0-59'
            }

  validates :time_start_second,
            allow_nil:    true,
            numericality: {
              only_integer: true,
              greater_than: -1, less_than: 60,
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

  # @todo factor these out (see also TaxonDetermination, Source::Bibtex)
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

  # @todo these are just simple integer validations now, fix!
  validates :start_date_month,
            numericality: {only_integer: true, greater_than: 0, less_than: 13},
            unless:       'start_date_month.blank?'

  validates :end_date_month,
            numericality: {only_integer: true, greater_than: 0, less_than: 13},
            unless:       'end_date_month.blank?'

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

  # @param [String]
  def verbatim_label=(value)
    write_attribute(:verbatim_label, value)
    write_attribute(:md5_of_verbatim_label, Utilities::Strings.generate_md5(value))
  end

  class << self

    #
    # Scopes
    #

    # @param geographic_item [GeographicItem]
    # @return [Scope]
    # TODO: use joins(:geographic_items).where(containing scope), simplied to
    def contained_within(geographic_item)
      CollectingEvent.joins(:geographic_items).where(GeographicItem.contained_by_where_sql(geographic_item.id))

      # pieces = GeographicItem.joins(:georeferences).is_contained_by('any', geographic_item)
      # # pieces = GeographicItem.is_contained_by('any', geographic_item)
      # pieces

      # ce = []
      # pieces.each { |o|
      #   ce.push(o.collecting_events_through_georeferences.to_a)
      #   ce.push(o.collecting_events_through_georeference_error_geographic_item.to_a)
      # }
      # pieces = CollectingEvent.where('id in (?)', ce.flatten.map(&:id).uniq)

      # pieces.excluding(self)
    end

    # @param collecting_events [CollectingEvent Scope]
    # @return [Scope] without self (if included)
    # TODO: DRY, use general form of this
    def excluding(collecting_events)
      where.not(id: collecting_events)
    end

    # @param params [Hash] of parameters for this search
    # @return [Scope] of collecting_events found by (partial) verbatim_locality
    def find_for_autocomplete(params)
      Queries::CollectingEventAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
    end

    #
    # Other
    #

    # engineered for st_flexpicker/en_flexpicker (yyyy/mm/dd)
    # @param [String] st_date (yyyy/mm/dd)
    # @param [String] end_date (yyyy/mm/dd)
    # @param [Boolean] greedy default = true,
    #                           false; found range must be completely inside supplied range
    #                           true; found range is only required to start inside supplied range
    # @return [String] sql for records between the two specific dates
    def date_sql_from_dates(st_date, end_date, greedy = true)
      parts    = st_date.split('/')
      st_year  = parts[0].to_i
      st_month = parts[1].to_i
      st_day   = parts[2].to_i

      parts     = end_date.split('/')
      end_year  = parts[0].to_i
      end_month = parts[1].to_i
      end_day   = parts[2].to_i

      part_0  = 'start_date_year is not null'

      # start_date is inside supplied range
      # string has to have four pieces:
      #   0) ignore start dates with no start year
      #   1) last part of start year
      #   2) any full years between start and end
      #   3) first part of last year

      part_1s = "(start_date_year = #{st_year}"
      part_1s += " and ((start_date_month between #{st_month + 1} and 12)"
      part_1s += " or (start_date_month = #{st_month} and start_date_day >= #{st_day})))"

      part_3s = "(start_date_year = #{end_year}"
      part_3s += " and ((start_date_month < #{end_month})"
      part_3s += " or (start_date_month = #{end_month} and start_date_day <= #{end_day})))"

      # end_date is inside supplied range
      # string has to have three pieces:
      #   1) last part of start year
      #   2) any full years between start and end
      #   3) first part of last year

      part_1e = "(end_date_year = #{end_year}"
      part_1e += " and ((end_date_month between 1 and #{end_month - 1})"
      part_1e += " or (end_date_month = #{end_month} and end_date_day <= #{end_day})))"

      part_3e = "(end_date_year = #{end_year}"
      part_3e += " and ((end_date_month > #{end_month})"
      part_3e += " or (end_date_month = #{end_month} and end_date_day >= #{end_day})))"

      if (st_year == end_year) or (end_year - st_year < 2) # test for whole years between date extent
        part_2s = '' # if no whole years, remove clause
        part_2e = ''
      else
        part_2s = "(start_date_year between #{st_year + 1} and #{end_year - 1})"
        part_2e = part_2s
      end

      st_string = "(#{part_0} and #{part_1s} and #{part_3s})#{part_2s.blank? ? '' : " or #{part_2s}"}"

      en_string = part_1e + ' and ' + part_3e + (part_2e.blank? ? '' : ' or ') + part_2e

      if greedy
        connect = ' or '
      else
        connect = ' and '
      end
      sql_string = st_string + connect + en_string
      sql_string
    end

    # @param [Hash] params of parameters
    # @return [Scope] of selected collecting events with georeferences
    def in_date_range_sql(params)
      sql_string = date_sql_from_dates(params[:st_flexpicker], params[:en_flexpicker])
      CollectingEvent.where(sql_string).uniq
    end

    # @param [Hash] of parameters in the style of 'params'
    # @return [Scope] of selected collecting_events
    # TODO: ARELIZE, likely in lib/queries
    def filter(params)
      sql_string = ''
      unless params.blank? # not strictly necessary, but handy for debugging
        sql_string          = Utilities::Dates.date_sql_from_params(params)

        # processing text data
        v_locality_fragment = params['verbatim_locality_text']
        any_label_fragment  = params['any_label_text']
        id_fragment         = params['identifier_text']

        prefix = ''
        unless v_locality_fragment.blank?
          unless sql_string.blank?
            prefix = ' and '
          end
          sql_string += "#{ prefix }verbatim_locality ilike '%#{v_locality_fragment}%'"
        end
        prefix = ''
        unless any_label_fragment.blank?
          unless sql_string.blank?
            prefix = 'and '
          end
          sql_string += "#{ prefix }(verbatim_label ilike '%#{any_label_fragment}%'"
          sql_string += " or print_label ilike '%#{any_label_fragment}%'"
          sql_string += " or document_label ilike '%#{any_label_fragment}%'"
          sql_string += ')'
        end

        unless id_fragment.blank?
          # @todo this still needs to be dealt with
        end

      end
      # find the records
      if sql_string.blank?
        collecting_events = CollectingEvent.where('false')
      else
        collecting_events = CollectingEvent.where(sql_string).uniq
      end

      collecting_events
    end

    # @param [Scope]
    # @return [CSV]
    def generate_download(scope)
      CSV.generate do |csv|
        csv << column_names
        scope.order(id: :asc).each do |o|
          csv << o.attributes.values_at(*column_names).collect { |i|
            i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
          }
        end
      end
    end

    # @return [true]
    #   A development method only. Attempts to create a verbatim georeference for every
    #   collecting event record that doesn't have one.
    #   TODO: this needs to be in a rake task or somewhere else
    def update_verbatim_georeferences
      if Rails.env == 'production'
        puts "You can't run this in #{Rails.env} mode."
        exit
      end

      passed    = 0
      failed    = 0
      attempted = 0

      CollectingEvent.includes(:georeferences).where(georeferences: {id: nil}).each do |c|
        next if c.verbatim_latitude.blank? || c.verbatim_longitude.blank?
        attempted += 1
        g         = c.generate_verbatim_data_georeference(true)
        if g.errors.empty?
          passed += 1
          puts "created for #{c.id}"
        else
          failed += 1
          puts "failed for #{c.id}, #{g.errors.messages}"
        end
      end

      puts "passed: #{passed}"
      puts "failed: #{failed}"
      puts "attempted: #{attempted}"
      true
    end

    def data_attributes
      column_names.reject { |c| %w{id project_id created_by_id updated_by_id created_at updated_at project_id}.include?(c) || c =~ /^cached/ }
    end

  end # << end class methods

  def has_data?
    CollectingEvent.data_attributes.each do |a|
      return true if !self.send(a).blank?
    end
    return true if georeferences.any?
    false
  end

  # @return [Boolean]
  def has_start_date?
    !start_date_day.blank? && !start_date_month.blank? && !start_date_year.blank?
  end

  # @return [Boolean]
  def has_end_date?
    !end_date_day.blank? && !end_date_month.blank? && !end_date_year.blank?
  end

  # @return [String]
  def end_date_string
    date = end_date
    "#{'%02d' % date.day}/#{'%02d' % date.month}/#{'%4d' % date.year}" unless date.nil?
  end

  # @return [String]
  def start_date_string
    date = start_date
    "#{'%02d' % date.day}/#{'%02d' % date.month}/#{'%4d' % date.year}" unless date.nil?
  end

  # @return [Time]
  def end_date
    Utilities::Dates.nomenclature_date(end_date_day, end_date_month, end_date_year)
  end

  # @return [Time]
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

  # CollectingEvent.select {|d| !(d.verbatim_latitude.nil? || d.verbatim_longitude.nil?)}
  # .select {|ce| ce.georeferences.empty?}
  # @param [Boolean] reference_self
  # @return [Georeference::VerbatimData, false]
  #   generates (creates) a Georeference::VerbatimReference from verbatim_latitude and verbatim_longitude values
  def generate_verbatim_data_georeference(reference_self = false, no_cached: false)
    return false if (verbatim_latitude.nil? || verbatim_longitude.nil?)
    begin
      CollectingEvent.transaction do
        vg_attributes = {collecting_event_id: self.to_param, no_cached: no_cached}
        vg_attributes.merge!(by: self.creator.id, project_id: self.project_id) if reference_self
        a = Georeference::VerbatimData.new(vg_attributes)
        if a.valid?
          a.save
        end
        return a
      end
    rescue
      raise
    end
    false
  end

  # @return [GeographicItem, nil]
  #    a GeographicItem instance representing a translation of the verbaitm values, not saved
  def build_verbatim_geographic_item
    if self.verbatim_latitude && self.verbatim_longitude && !self.new_record?
      local_latitude  = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(verbatim_latitude)
      local_longitude = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(verbatim_longitude)
      elev            = Utilities::Geo.distance_in_meters(verbatim_elevation)
      point           = Gis::FACTORY.point(local_latitude, local_longitude, elev)
      GeographicItem.new(point: point)
    else
      nil
    end
  end

  # @return [Integer]
  # @todo figure out how to convert verbatim_geolocation_uncertainty in different units (ft, m, km, mi) into meters
  def get_error_radius
    return nil if verbatim_geolocation_uncertainty.blank?
    return verbatim_geolocation_uncertainty.to_i if is.number?(verbatim_geolocation_uncertainty)
    nil
  end

  # @return [Scope]
  #   all geographic_items associated with this collecting_event through georeferences only
  def all_geographic_items
    GeographicItem.
      joins('LEFT JOIN georeferences g2 ON geographic_items.id = g2.error_geographic_item_id').
      joins('LEFT JOIN georeferences g1 ON geographic_items.id = g1.geographic_item_id').
      where(['(g1.collecting_event_id = ? OR g2.collecting_event_id = ?) AND (g1.geographic_item_id IS NOT NULL OR g2.error_geographic_item_id IS NOT NULL)', self.id, self.id])
  end

  # @return [GeographicItem, nil]
  #  returns the geographic_item corresponding to the geographic area, if provided
  def geographic_area_default_geographic_item
    try(:geographic_area).try(:default_geographic_item)
  end

  # @param [GeographicItem]
  # @return [String]
  #   see how far away we are from another gi
  def distance_to(geographic_item_id)
    GeographicItem.distance_between(preferred_georeference.geographic_item_id, geographic_item_id)
  end

  # @param [Double] distance in meters
  # @return [Scope]
  def collecting_events_within_radius_of(distance)
    return CollectingEvent.where(id: -1) if !preferred_georeference
    geographic_item_id = preferred_georeference.geographic_item_id
    CollectingEvent.not_self(self)
      .joins(:geographic_items)
      .where(GeographicItem.within_radius_of_item_sql(geographic_item_id, distance))
  end

  # @return [Scope]
  # Find all (other) CEs which have GIs or EGIs (through georeferences) which intersect self
  def collecting_events_intersecting_with
    pieces = GeographicItem.with_collecting_event_through_georeferences.intersecting('any', self.geographic_items.first).uniq
    gr     = [] # all collecting events for a geographic_item

    pieces.each { |o|
      gr.push(o.collecting_events_through_georeferences.to_a)
      gr.push(o.collecting_events_through_georeference_error_geographic_item.to_a)
    }

    # @todo change 'id in (?)' to some other sql construct
    pieces = CollectingEvent.where(id: gr.flatten.map(&:id).uniq)
    pieces.excluding(self)
  end

  # @return [Scope]
  # Find other CEs that have GRs whose GIs or EGIs are contained in the EGI

  def collecting_events_contained_in_error
    # find all the GIs and EGIs associated with CEs
    # TODO: this will be impossibly slow in present form
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

    # @todo Directly map this
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

  # @param [String]
  #   one or more names from GeographicAreaType
  # @return [Hash]
  #    (
  #    {'name' => [GAs]}
  #   or
  #   [{'name' => [GAs]}, {'name' => [GAs]}]
  #   )
  #     one hash, consisting of a country name paired with an array of the corresponding GAs, or
  #     an array of all of the hashes (name/GA pairs),
  #     which are country_level, and have GIs containing the (GI and/or EGI) of this CE
  # @todo this needs more work, possibily direct AREL table manipulation.
  def name_hash(types)
    retval  = {}
    gi_list = containing_geographic_items

    # there are a few ways we can end up with no GIs
    # unless gi_list.nil? # no references GeographicAreas or Georeferences at all, or
    unless gi_list.empty? # no available GeographicItems to test
      # map the resulting GIs to their corresponding GAs
      # pieces  = GeographicItem.where(id: gi_list.flatten.map(&:id).uniq)
      # pieces = gi_list
      ga_list = GeographicArea.joins(:geographic_area_type, :geographic_areas_geographic_items).
        where(geographic_area_types:             {name: types},
              geographic_areas_geographic_items: {geographic_item_id: gi_list}).uniq

      # WAS: now find all of the GAs which have the same names as the ones we collected.

      # map the names to an array of results
      ga_list.each { |i|
        retval[i.name] ||= [] # if we haven't come across this name yet, set it to point to a blank array
        retval[i.name].push i # we now have at least a blank array, push the result into it
      }
    end
    # end
    retval
  end

  # @return [Hash]
  #   classifies this collecting event into country, state, county categories
  def geographic_name_classification
    # if names are stored in the database, and the the geographic_area_id has not changed
    if has_cached_geographic_names? && !geographic_area_id_changed?
      return cached_geographic_name_classification
    else
      r = get_geographic_name_classification
      cache_geographic_names(r, true)
    end
  end

  def get_geographic_name_classification
    case geographic_name_classification_method
      when :preferred_georeference
        # quick
        r = preferred_georeference.geographic_item.quick_geographic_name_hierarchy # almost never the case, UI not setup to do this
        # slow
        r = preferred_georeference.geographic_item.inferred_geographic_name_hierarchy if r == {} # therefor defaults to slow
      when :geographic_area_with_shape # geographic_area.try(:has_shape?)
        # quick
        r = geographic_area.geographic_name_classification # do not round trip to the geographic_item, it just points back to the geographic area
        # slow
        r = geographic_area.default_geographic_item.inferred_geographic_name_hierarchy if r == {}
      when :geographic_area # elsif geographic_area
        # quick
        r = geographic_area.geographic_name_classification
      when :verbatim_map_center # elsif map_center
        # slowest
        r = GeographicItem.point_inferred_geographic_name_hierarchy(verbatim_map_center)
    end
    r ||= {}
  end

  def has_cached_geographic_names?
    cached_geographic_name_classification != {}
  end

  def cached_geographic_name_classification
    h           = {}
    h[:country] = cached_level0_geographic_name if cached_level0_geographic_name
    h[:state]   = cached_level1_geographic_name if cached_level1_geographic_name
    h[:county]  = cached_level2_geographic_name if cached_level2_geographic_name
    h
  end

  def cache_geographic_names(values = {}, tried = false)
    values = get_geographic_name_classification if values.empty? && !tried # prevent a second call to get if we've already tried through
    return {} if values.empty?
    update_column(:cached_level0_geographic_name, values[:country])
    update_column(:cached_level1_geographic_name, values[:state])
    update_column(:cached_level2_geographic_name, values[:county])
    values
  end

  # @return [Symbol, nil]
  #    determines (prioritizes) the method to be used to decided the geographic name classification
  #    (string labels for country, state, county) for this collecting_event.
  def geographic_name_classification_method
    return :preferred_georeference if preferred_georeference
    return :geographic_area_with_shape if geographic_area.try(:has_shape?)
    return :geographic_area if geographic_area
    return :verbatim_map_center if verbatim_map_center
    nil
  end

  # @return [Array of GeographicItems containing this target]
  #   GeographicItems are those that contain either the georeference or, if there are none,
  #   the geographic area
  def containing_geographic_items
    gi_list = []
    if self.georeferences.any?
      # gather all the GIs which contain this GI or EGI
      #
      #  Struck EGI, EGI must contain GI, therefor anything that contains EGI contains GI, threfor containing GI will always be the bigger set
      #   !! and there was no tests broken
      # GeographicItem.are_contained_in_item('any_poly', self.geographic_items.to_a).pluck(:id).uniq
      gi_list = GeographicItem.containing(*geographic_items.pluck(:id)).pluck(:id).uniq

    else
      # use geographic_area only if there are no GIs or EGIs
      unless self.geographic_area.nil?
        # unless self.geographic_area.geographic_items.empty?
        # we need to use the geographic_area directly
        gi_list = GeographicItem.are_contained_in_item('any_poly', self.geographic_area.geographic_items).pluck(:id).uniq
        # end
      end
    end
    gi_list
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
    return nil if name_hash.keys.count == 0
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

  alias county_name county_or_equivalent_name

  # @return [Symbol, nil]
  #   prioritizes and identifies the source of the latitude/longitude values that
  #   will be calculated for DWCA and primary display
  def lat_long_source
    if preferred_georeference
      :georeference
    elsif verbatim_latitude && verbatim_longitude
      :verbatim
    elsif geographic_area && geographic_area.has_shape?
      :geographic_area
    else
      nil
    end
  end

=begin

# @todo @mjy: please fill in any other paths you can think of for the acquisition of information for the seven below listed items
  ce.georeference.geographic_item.centroid
  ce.georeference.error_geographic_item.centroid
  ce.verbatim_georeference
  ce.preferred_georeference
  ce.georeference.first
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
  #   parameters from collecting event that are of use to geolocate
  def geolocate_attributes
    parameters = {
      'country'   => country_name,
      'state'     => state_or_province_name,
      'county'    => county_or_equivalent_name,
      'locality'  => verbatim_locality,
      'Placename' => verbatim_locality,
    }

    focus = case lat_long_source
              when :georeference
                preferred_georeference.geographic_item
              when :geographic_area
                geographic_area.geographic_area_map_focus
              else
                nil
            end

    parameters.merge!(
      'Longitude' => focus.point.x,
      'Latitude'  => focus.point.y
    ) unless focus.nil?
    parameters
  end

  def latitude
    verbatim_map_center.try(:x)
  end

  def longitude
    verbatim_map_center.try(:y)
  end

  # @return [Hash]
  #    a complete set of params necessary to form a request string
  def geolocate_ui_params
    Georeference::GeoLocate::RequestUI.new(geolocate_attributes).request_params_hash
  end

  # @return [String]
  def geolocate_ui_params_string
    Georeference::GeoLocate::RequestUI.new(geolocate_attributes).request_params_string
  end

  # @return [GeoJSON::Feature]
  #   the first geographic item of the first georeference on this collecting event
  def to_geo_json_feature
    # !! avoid loading the whole geographic item, just grab the bits we need:
    # self.georeferences(true)  # do this to
    to_simple_json_feature.merge({
                                   'properties' => {
                                     'collecting_event' => {
                                       'id'  => self.id,
                                       'tag' => "Collecting event #{self.id}."
                                     }
                                   }
                                 })
  end

  # TODO: parametrize to include gazeteer
  #   i.e. geographic_areas_geogrpahic_items.where( gaz = 'some string')
  def to_simple_json_feature
    base = {
      'type'       => 'Feature',
      'properties' => {}
    }

    if geographic_items.any?
      geo_item_id      = geographic_items.select(:id).first.id
      base['geometry'] = JSON.parse(GeographicItem.select("ST_AsGeoJSON(#{GeographicItem::GEOMETRY_SQL}::geometry) geo_json").find(geo_item_id).geo_json)
    end
    base
  end

  # @return [CollectingEvent]
  #   return the next collecting event without a georeference in this collecting events project sort order
  #   1.  verbatim_locality
  #   2.  geography_id
  #   3.  start_date_year
  #   4.  updated_on
  #   5.  id
  def next_without_georeference
    CollectingEvent.excluding(self).
      includes(:georeferences).
      where(project_id: self.project_id, georeferences: {collecting_event_id: nil}).
      order(:verbatim_locality, :geographic_area_id, :start_date_year, :updated_at, :id).
      first
  end

  # @param [Float] delta_z, will be used to fill in the z coordinate of the point
  # @return [RGeo::Geographic::ProjectedPointImpl, nil]
  #    for the *verbatim* latitude/longitude only
  def verbatim_map_center(delta_z = 0.0)
    unless verbatim_latitude.blank? or verbatim_longitude.blank?
      lat     = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(verbatim_latitude.to_s)
      long    = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(verbatim_longitude.to_s)
      elev    = Utilities::Geo.distance_in_meters(verbatim_elevation.to_s)
      delta_z = elev unless elev == 0.0
      Gis::FACTORY.point(long, lat, delta_z)
    else
      nil
    end
  end

  # @return [Symbol, nil]
  #   the name of the method that will return an Rgeo object that represent
  #   the "preferred" centroid for this collecting event
  def map_center_method
    return :preferred_georeference if preferred_georeference # => { georeferenceProtocol => ?  }
    return :verbatim_map_center if verbatim_map_center # => { }
    return :geographic_area if geographic_area.try(:has_shape?)
    nil
  end

  # http://tools.gbif.org/dwca-assistant/
  def dwca_map_center_attributes
    #return {
    #  ...
    #}
  end

  # @return [Rgeo::Geographic::ProjectedPointImpl, nil]
  def map_center
    case map_center_method
      when :geographic_area
        geographic_area.default_geographic_item.geo_object.centroid
      when :verbatim_map_center
        verbatim_map_center
      when :preferred_georeference
        preferred_georeference.geographic_item.centroid
      else
        nil
    end
  end

  def names
    geographic_area.nil? ? [] : geographic_area.self_and_ancestors.where("name != 'Earth'").collect { |ga| ga.name }
  end

  def georeference_latitude
    retval = 0.0
    if georeferences.count > 0
      retval = Georeference.where(collecting_event_id: self.id).order(:position).limit(1)[0].latitude.to_f
      # retval = georeferences.first?.latitude
    end
    retval.round(6)
  end

  def georeference_longitude
    retval = 0.0
    if georeferences.count > 0
      retval = Georeference.where(collecting_event_id: self.id).order(:position).limit(1)[0].longitude.to_f
    end
    retval.round(6)
  end

  # @return [String]
  #   coordinates for centering a Google map
  def verbatim_center_coordinates
    if self.verbatim_latitude.blank? || self.verbatim_longitude.blank?
      'POINT (0.0 0.0 0.0)'
    else
      self.verbatim_map_center.to_s
    end
  end

  def level0_name
    return cached_level0_name if cached_level0_name
    cache_geographic_names[:country]
  end

  def level1_name
    return cached_level1_name if cached_level1_name
    cache_geographic_names[:state]
  end

  def level2_name
    return cached_level0_name if cached_level0_name
    cache_geographic_names[:state]
  end

  def cached_level0_name
    return cached_level0_name if cached_level0_name
    cache_geographic_names[:state]
  end

  protected

  def set_cached
    if !verbatim_label.blank?
      string = verbatim_label
    elsif !print_label.blank?
      string = print_label
    elsif !document_label.blank?
      string = document_label
    else
      name       = cached_geographic_name_classification.values.join(': ')
      date       = [start_date_string, end_date_string].compact.join('-')
      place_date = [verbatim_locality, date].compact.join(', ')
      string     = [name, place_date, verbatim_collectors, verbatim_method].select { |a| !a.blank? }.join("\n")
    end

    string = "[#{self.to_param}]" if string.blank?

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
    errors.add(:base, 'End date without start date.') if (has_end_date? && !has_start_date?)
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
