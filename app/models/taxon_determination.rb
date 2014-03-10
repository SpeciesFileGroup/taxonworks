# @!attribute otu
#   @return [Otu] 
#   the OTU (concept) of the determination 
# @!attribute biological_collection_object 
#   @return [BiologicalCollectionObject] 
#   The object being determined.
# @!attribute determiner
#   @return [Person]
#   the Person making the determination
# @!attribute year_made
#   @return [String] 
#   the year the determination was made, abbreviations like '02' are allowed
# @!attribute month_made
#   @return [String] 
#   the month the determination was made. Literal values like Roman Numerals, abbreviations ('Jan.') etc. are allowed, but not all forms can be interpreted.
# @!attribute day_made
#   @return [String] 
#   the day of the month the determination was made 
class TaxonDetermination < ActiveRecord::Base
  acts_as_list scope: [:biological_collection_object_id]

  include Housekeeping
  include Shared::HasRoles
  include Shared::Citable

  belongs_to :otu
  belongs_to :biological_collection_object

  has_one :determiner_role, class_name: 'Determiner', as: :role_object
  has_one :determiner, through: :determiner_role, source: :person

  def sort_date
    Utilities::Dates.nomenclature_date(day_made, month_made, year_made)
  end

  before_save :set_made_fields_if_none_provided

  protected

  def set_made_fields_if_none_provided
    byebug
    if year_made.blank? && month_made.blank? && day_made.blank?
      year_made = Time.now.year 
      month_made = Time.now.month
      day_made = Time.now.day
    end
  end

end
