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

  # "Hard" Validations
  validates_presence_of :name

  # "Soft" Validations
  soft_validate(:sv_duplicate?)

  # Getters/Setters

  # Class methods

  # Instance methods
  def duplicate?
    # Boolean is there another serial with the same name?
    if self.new_record?
      Serial.exists?(name: self.name)
    else
      dup = Serial.where("name = ? AND id <> ?", self.name, self.id)
    end

  end
  protected


  def sv_duplicate?
    if self.duplicate?
      soft_validations.add(:name, 'There is another serial with this name in the database.')
    end
  end

  # TODO soft validation of name matching an alternate value for name of a different serial

end
