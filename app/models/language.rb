# This is a 1:1 representation of ISO 639-2.
# It is built on initialization with a rake task, and not further touched.
# attribute alpha_3_bibliographic always has a distinct 3 character value
# alpha_2 will have either a 2 character value or and empty string ('')
# english_name or french_name may be more than one word long
# (e.g. 'English, Middle (1100-1500)', 'Filipino; Pilipino','Finno-Ugrian languages')
# and many of the languages have multiple version (e.g. there are 4 variations of German)
#
# @!attribute alpha_3_bibiographic
#   @return [String]
#   @todo
#
# @!attribute alpha_3_terminologic
#   @return [String]
#   @todo
#
# @!attribute alpha_2
#   @return [String]
#   @todo
#
# @!attribute english_name
#   @return [String]
#   @todo
#
# @!attribute french_name
#   @return [String]
#   @todo
#
class Language < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData 
  include Shared::IsApplicationData

  has_many :serials, inverse_of: :language
  has_many :sources, inverse_of: :source_language

  # Scopes
  scope :with_english_name_containing, ->(name) {where('english_name ILIKE ?', "%#{name}%")}  # non-case sensitive comparison

  #Validations
  validates_presence_of :english_name, :alpha_3_bibliographic


  def self.with_english_name_or_abbreviation(value)
    value = [value] if value.class == String

    t = Language.arel_table
    a = t[:english_name].matches_any(value)
    b = t[:alpha_2].matches_any(value)
    c = t[:alpha_3_bibliographic].matches_any(value)
    d = t[:alpha_3_terminologic].matches_any(value)
     Language.where(a.or(b).or(c).or(d).to_sql)

  end

  def self.find_for_autocomplete(params)
    term = "#{params[:term]}%"
    where('english_name ILIKE ? OR english_name = ?', term, params[:term] )  
  end

end
