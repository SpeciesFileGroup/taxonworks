# Serial - represents a journal or other serial (repeated) publication. It follows the ISSN model for serials.
#
# @!attribute place_published
#   @return [String]
#     The name of the place(s) where the serial is published.
#
# @!attribute primary_language_id
#   @return [Integer]
#   The id of the Language - language of this serial.  According to the ISSN a new ISSN is minted for a journal that
#     changes languages.
#
# @!attribute first_year_of_issue
#   @return [Integer]
#     the first year this serial was published
#
# @!attribute last_year_of_issue
#   @return [Integer]
#     the last year this serial was published
#
# @!attribute translated_from_serial_id
#   @return [Integer]
#     the id of the serial that this serial is a direct translation of 
#
# @!attribute publisher
#   @return [String]
#    the serial publisher
#
# @!attribute name
#   @return [String]
#     the name of the serial
#
# TODO handle translations (which are simultaneous)
class Serial < ApplicationRecord
  
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Notes
  include Shared::Identifiers
  include Shared::Tags
  include Shared::IsData
  include SoftValidation
  include Shared::SharedAcrossProjects
  include Shared::HasPapertrail

  ALTERNATE_VALUES_FOR = [:name, :publisher, :place_published].freeze
  
  belongs_to :translated_from_serial, foreign_key: :translated_from_serial_id, class_name: 'Serial'
  belongs_to :language, foreign_key: :primary_language_id

  has_many :sources, class_name: 'Source::Bibtex', inverse_of: :serial, dependent: :restrict_with_error
  has_many :translations, foreign_key: :translated_from_serial_id, class_name: 'Serial'

  has_many :succeeding_serial_chronologies, foreign_key: :succeeding_serial_id, class_name: 'SerialChronology'
  has_many :preceding_serial_chronologies, foreign_key: :preceding_serial_id, class_name: 'SerialChronology'

  # single preceding chronology will be multiple serials if there is a merge
  has_many :immediately_preceding_serials, through: :succeeding_serial_chronologies, source: :preceding_serial

  # single succeeding chronology will be multiple serials if there is a split
  has_many :immediately_succeeding_serials, through: :preceding_serial_chronologies, source: :succeeding_serial

  accepts_nested_attributes_for :alternate_values, reject_if: lambda { |av| av[:value].blank? }, allow_destroy: true

  validates_presence_of :name

  soft_validate(:sv_duplicate?)

  # @param [String] compared_string
  # @param [String] column
  # @param [Integer] limit
  # @return [Scope]
  #   Levenshtein calculated related records per supplied column
  def nearest_by_levenshtein(compared_string = nil, column = 'name', limit = 10)
    return Serial.none if compared_string.blank?

    # Levenshtein in postgres requires all strings be 255 or fewer
    order_str = Serial.send(
      :sanitize_sql_for_conditions,
      ["levenshtein(Substring(serials.#{column} from 0 for 250), ?)",
       compared_string[0..250]])

    Serial.where('id <> ?', self.to_param)
      .order(Arel.sql(order_str)) 
      .limit(limit)
  end

  # @return [Boolean]
  #   is there another serial with the same name?  Also checkes alternate values.
  def duplicate?
    # ret_val = false
    if self.new_record?
      ret_val = Serial.exists?(name: self.name)
    else
      name_str = ActiveRecord::Base.send(
        :sanitize_sql_array, 
        ['name = ? AND NOT (id = ?)',
         Utilities::Strings.escape_single_quote(self.name),
         self.id])
      ret_val  = Serial.where(name_str).to_a.size > 0
    end

    if ret_val == false
      # check if there is another alternate value with the same name
      a = Serial.with_alternate_value_on(:name, self.name)
      # select alternate value based on alternate_value_object class, alternate_value_object_attribute(column) & value
      if a.count > 0
        ret_val = true
      end
    end
    ret_val
  end

=begin
  def full_chronology
    # return ordered array of serials associated with this serial
  end
=end

  # @param [Serial] start_serial
  # @return [Array]
  def all_previous(start_serial = self)
    # provides an array of all previous incarnations of me

    out_array = []
    start_serial.immediately_preceding_serials.order(:name).each do |serial|
      out_array.push(serial)
      prev = all_previous(serial)

      out_array.push(prev) unless prev.empty?
    end
    return out_array
  end

  # @param [Serial] start_serial
  # @return [Array]
  def all_succeeding(start_serial = self)
    # provides an array of all succeeding incarnations of me
    out_array = []
    start_serial.immediately_succeeding_serials.order(:name).each do |serial|
      out_array.push(serial)
      succeeding = all_succeeding(serial)

      out_array.push(succeeding) unless succeeding.empty?
    end
    return out_array
  end

  def self.used_recently(user_id)
    t = Source.arel_table
    p = Serial.arel_table

    # i is a select manager
    i = t.project(t['serial_id'], t['created_at']).from(t)
            .where(t['created_at'].gt(1.weeks.ago))
            .where(t['created_by_id'].eq(user_id))
            .order(t['created_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    Serial.joins(
        Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['serial_id'].eq(p['id'])))
    ).pluck(:id).uniq
  end

  def self.select_optimized(user_id, project_id)
    r = used_recently(user_id)
    h = {
      recent: (
        Serial.where('"serials"."id" IN (?)', r.first(10) ).order(:name).to_a +
            Serial.where(created_by_id: user_id, created_at: 3.hours.ago..Time.now).limit(5).to_a).uniq,
      pinboard: Serial.pinned_by(user_id).pinned_in_project(project_id).to_a
    }

    h[:quick] = (Serial.pinned_by(user_id).pinboard_inserted.pinned_in_project(project_id).to_a +
        Serial.where('"serials"."id" IN (?)', r.first(4) ).order(:name).to_a).uniq
    h
  end

  protected

  # @return [Boolean]
  def sv_duplicate?
    if self.duplicate?
      soft_validations.add(:name, 'There is another serial with this name in the database.')
    end
    # TODO soft validation of name matching an alternate value for name of a different serial
  end

end
