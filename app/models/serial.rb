# Serial - represents a journal or other serial publication
#
# It will support abbreviations through Shared::AlternateValues.
# Serials are Notable, Taggable, and Identifiable.
#
class Serial < ActiveRecord::Base
  # Include statements, and acts_as_type
  include SoftValidation
  include Housekeeping::Users
  include Shared::Identifiable
  include Shared::Notable
  include Shared::AlternateValues   # abbreviations, alternate titles, language translations
  include Shared::DataAttributes
  include Shared::Taggable

  # Class constants
  # Class variables
  # Callbacks
  # Associations, in order: belongs_to, has_one,has_many
  has_many :serial_chronologies_as_succeeding, foreign_key: :subject_serial_id
  has_many :serial_chronologies_as_preceding, foreign_key: :subject_object_id
  has_many :succeeding_serials, through: :serial_chronologies_as_subject, class_name: 'Serial'
  has_many :preceding_serials, through: :serial_chronologies_as_object, class_name: 'Serial'

  # Scopes, clustered by function
  # select all serials with this name
  # select all serials with this abbreviation
  # select all serials with this translation name
  # select all serials that match this name or alternate value

  # "Hard" Validations
  validates_presence_of :name
  # TODO validate language

  # "Soft" Validations
  soft_validate(:sv_duplicate?)

  # Getters/Setters
  # TODO set language via string name

  # Class methods

  # Instance methods
  def duplicate?
    # Boolean is there another serial with the same name?
    ret_val = false
    if self.new_record?
      ret_val = Serial.exists?(name: self.name)
    else
      ret_val = Serial.where( "name = '#{self.name}' AND NOT (id = #{self.id})").to_a.count > 0
    end

    ret_val # return
  end

  def previous_serial
    # return previous serial object or nil
  end

  def succeeding_serial
    # return succeeding serial object or nil
  end

  def chronology
    # return ordered array of serials associated with this serial
  end

  protected


  def sv_duplicate?
    if self.duplicate?
      soft_validations.add(:name, 'There is another serial with this name in the database.')
    end
    # TODO soft validation of name matching an alternate value for name of a different serial
  end

  def match_alternate_value?
    #Select value from AlternateValue WHERE alternate_object_type = 'Serial' AND alternate_object_attribute = 'name'

  end
end
