# Serial - represents a journal or other serial publication. It follows the ISSN model for serials.
#
# @!attribute primary_language_id 
#   @return [Integer]
#   The id of the Language  langauge of this serial.  According to the ISSN a new ISSN is minted for a journal that changes languages.
#
class Serial < ActiveRecord::Base
  # Include statements, and acts_as_type
  include Housekeeping::Users
  include Shared::IsData 
  include Shared::SharedAcrossProjects
  include SoftValidation
  include Shared::Identifiable
  include Shared::Notable
  include Shared::AlternateValues # abbreviations, alternate titles, language translations
  include Shared::DataAttributes
  include Shared::Taggable

  # Class constants
  # Class variables
  # Callbacks
  # Associations, in order: belongs_to, has_one,has_many
  belongs_to :translated_from_serial, foreign_key: :translated_from_serial_id, class_name: 'Serial'
  belongs_to :language, foreign_key: :primary_language_id, class_name: 'Language'

  has_many :sources 

  has_many :translations, foreign_key: :translated_from_serial_id, class_name: 'Serial'

  has_many :succeeding_serial_chronologies, foreign_key: :succeeding_serial_id, class_name: 'SerialChronology'
  # all serialChronologies where SerialChronology.succeeding_serial_id = my.id

  has_many :preceding_serial_chronologies, foreign_key: :preceding_serial_id, class_name: 'SerialChronology'
  # all serialChronologies where SerialChronology.preceding_serial_id = my.id

  has_many :immediately_preceding_serials, through: :succeeding_serial_chronologies, source: :preceding_serial
  # .to_a will return an array of serials - single preceding chronology will be multiple serials if there is a merge

  has_many :immediately_succeeding_serials, through: :preceding_serial_chronologies, source: :succeeding_serial # class is 'Serial'
  # .to_a will return an array of serials - single succeeding chronology will be multiple serials if there is a split

  accepts_nested_attributes_for :alternate_values

  # TODO handle translations (which are simultaneous)

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
  # TODO follow question (7/16/14) - Matt - there are translations as different serials (different ISSNs) and translations of the name of the current serial which are alternate values
=end

  # "Hard" Validations
  validates_presence_of :name
  # TODO validate language
  #  language ID should be nil or in the language table - default language value of English will be set in view.

  # "Soft" Validations
  soft_validate(:sv_duplicate?)

  # Instance methods

  # Boolean is there another serial with the same name?
  def duplicate?
    ret_val = false
    if self.new_record?
      ret_val = Serial.exists?(name: self.name)
    else
      ret_val = Serial.where("name = '#{self.name}' AND NOT (id = #{self.id})").to_a.count > 0
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

=begin
  def full_chronology
    # return ordered array of serials associated with this serial
  end
=end

  def all_previous(start_serial=self)
    # provides an array of all previous incarnations of me

    out_array = []
    start_serial.immediately_preceding_serials.order(:name).each do |serial|
      out_array.push(serial)
      prev = all_previous(serial)

      out_array.push(prev) unless prev.empty?
    end
    return out_array
  end

  def all_succeeding(start_serial=self)
    # provides an array of all succeeding incarnations of me
    out_array = []
    start_serial.immediately_succeeding_serials.order(:name).each do |serial|
      out_array.push(serial)
      succeeding = all_succeeding(serial)

      out_array.push(succeeding) unless succeeding.empty?
    end
    return out_array
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
