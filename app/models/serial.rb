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
  # select all serials with this name this will handled by
  # TODO to be implemented include shared::scopes
  # ^= scope :with_<attribute name>, ->(<search value>) {where <attribute name>:<search value>}

=begin   discussion with Matt 4/16/2014 - types of likely searches
  Serial.with_name('foo')   vs.   Serial.where(name: 'foo')
  settled on above to do - create a shared scope so any attribute can be called as Class.with_<attr_name>

  params = {name:"J. Stuff", placed_published:"New York", creator: @beth}
  Serial.where(params)

  # select all serials that match this name or alternate value should be an alternate value scope?
  Serial.with_value_and_alternates(:name, 'Beth')
  # extend alternate value so that you look up via class;column_name;value

  # select all serials with this abbreviation - fine to implement scope here, but primary
    test should be in alternate value
  # select all serials with this translation name - fine to implement scope here, but primary
    test should be in alternate value
=end

  # "Hard" Validations
  validates_presence_of :name
  # TODO validate language
  #  language ID should be nil or in the language table - default language value of English will be set in view.

  # "Soft" Validations
  soft_validate(:sv_duplicate?)

  # Getters/Setters
  # TODO set language via string name (english_name: & french_name)  & short form (alpha_3_bibliographic)
  # set language based on 3 letter abbreviation (do not use 2 letter abbreviations because there are several missing)
  def language_abbrev=(value)
    lang = Language.exact_abr(value)
    if lang.nil?
      self.primary_language_id = nil
    else
      self.primary_language_id = lang.id
    end
   end
  def language_abbrev
     lang = Language.where(id: self.primary_language_id).to_a[0].alpha_3_bibliographic
  end

  def language=(value)
    lang = Language.exact_eng(value)
    if lang.nil?
      self.primary_language_id = nil
    else
      self.primary_language_id = lang.id
    end
  end
  def language
    lang = Language.where(id: self.primary_language_id).to_a[0].english_name
  end

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

    if ret_val == false
      # check if there is another alternate value with the same name
      a = Serial.with_alternate_value_on(:name, self.name)
      # select alternate value based on alternate_object class, alternate_object_attribute(column) & value
      if a.count > 0
        ret_val = true
      end
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
