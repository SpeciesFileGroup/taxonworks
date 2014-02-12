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
# @!attribute verbatim_longitude
#   @return [String]
#   A string, typically sliced from verbatim_label, that represents the latitude. Is used to derive mappable values, but does not get mapped itself. 
class CollectingEvent < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::Identifiable
  include Shared::Notable
  include SoftValidation

  belongs_to :geographic_area, inverse_of: :collecting_events
  has_many :collector_roles, class_name: 'Collector', as: :role_object
  has_many :collectors, through: :collector_roles, source: :person

  before_validation :check_verbatim_geolocation_uncertainty,
                    :check_date_range,
                    :check_elevation_range

  validates_uniqueness_of :md5_of_verbatim_label, scope: [:project_id]
  validates_presence_of :verbatim_longitude, if: '!verbatim_latitude.blank?'
  validates_presence_of :verbatim_latitude, if: '!verbatim_longitude.blank?'

  validates_numericality_of :start_date_year,
    only_integer: true, greater_than: 0,
    less_than_or_equal_to: Time.now.year,
    allow_nil: true,
    message: 'start date year must be an integer greater than 0'
  validates_inclusion_of :start_date_month,
    in: 1..12, 
    allow_nil: true,
    message: ' start date month'
  validates_numericality_of :start_date_day,
    allow_nil: true,
    only_integer: true,
    greater_than: 0,
    less_than_or_equal_to: Proc.new { |a| Time.utc(a.start_date_year, a.start_date_month).end_of_month.day },
    :unless => 'start_date_year.nil? || start_date_month.nil?',
    message: '%{value} is not a valid start_date_day for the month provided'
  validates_numericality_of :end_date_year,
    only_integer: true, greater_than: 0,
    less_than_or_equal_to: Time.now.year,
    allow_nil: true,
    message: 'start date year must be an integer greater than 0'
  validates_inclusion_of :end_date_month,
    in: 1..12,
    allow_nil: true,
    message: ' start date month'
  validates_numericality_of :end_date_day,
    allow_nil: true,
    only_integer: true,
    greater_than: 0,
    less_than_or_equal_to: Proc.new { |a| Time.utc(a.end_date_year, a.end_date_month).end_of_month.day },
    :unless => 'end_date_year.nil? || end_date_month.nil?',
    message: '%{value} is not a valid end_date_day for the month provided'

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
    has_end_date? && Utilities::Dates.nomenclature_date(end_date_day, end_date_month, end_date_year)  
  end

  def start_date
    has_start_date? && Utilities::Dates.nomenclature_date(start_date_day, start_date_month, start_date_year)  
  end 

  protected

  def check_verbatim_geolocation_uncertainty
    errors.add(:verbatim_geolocation_uncertainty, 'Provide both verbatim_latitude and verbatim_longitude if you provide verbatim_uncertainty.') if !verbatim_geolocation_uncertainty.blank? && verbatim_longitude.blank? && verbatim_latitude.blank?
  end

  def check_date_range
    errors.add(:base, 'End date is earlier than start date.') if has_start_date? && has_end_date? && (start_date > end_date)
  end

  def check_elevation_range
    errors.add(:maximum_elevation,  'Maximum elevation is lower than minimum elevation.') if !minimum_elevation.blank? && !maximum_elevation.blank? && maximum_elevation < minimum_elevation
  end

  def sv_minimally_check_for_a_label
    [:verbatim_label, :print_label, :document_label, :field_notes].each do |v|
      return true if !self.send(v).blank?
    end 

    soft_validations.add(:base, 'At least one label type, or field notes, should be provided.')
  end

end
