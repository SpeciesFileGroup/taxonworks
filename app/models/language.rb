# This is a 1:1 representation of ISO 639-2.
# It is built on initialization with a rake task, and not further touched.
# attribute alpha_3_bibliographic always has a distinct 3 character value
# alpha_2 will have either a 2 character value or and empty string ('')
# english_name or french_name may be more than one word long
# (e.g. 'English, Middle (1100-1500)', 'Filipino; Pilipino','Finno-Ugrian languages')
# and many of the languages have multiple version (e.g. there are 4 variations of German)
class Language < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData 


  # Scopes
  scope :eng_name_contains, ->(name) {where('english_name ILIKE ?', "%#{name}%")}  # non-case sensitive comparison

  #Validations
  validates_presence_of :english_name, :alpha_3_bibliographic

  #returns nil or single object
  def self.exact_abr(abbr)
    a = where('alpha_3_bibliographic = ?', abbr).to_a
    if a.count == 0
      return nil
    else
      return a[0]
    end
  end

  #returns nil or single object
  def self.exact_eng(name)
    a = where('english_name = ?', name).to_a
    if a.count == 0
      return nil
    else
      return a[0]
    end

  end
end
