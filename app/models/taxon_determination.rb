# @!attribute [Otu] otu
#   The OTU (concept) behind the determination. 
# @!attribute [BiologicalCollectionObject] biological_collection_object 
#   The object being determined
# @!attribute [Person] determiner
#   The Person making the determination.
# @!attribute [String] year_made
#   The year the determination was made, abbreviations like '02' are allowed.
# @!attribute [String] month_made
#   The month the determination was made. Literal values like Roman Numerals, abbreviations ('Jan.') etc. are allowed, but not all forms can be interpreted.
# @!attribute [String] day_made
#   The day of the month the determination was made.  
class TaxonDetermination < ActiveRecord::Base

  include Shared::HasRoles

  belongs_to :otu
  belongs_to :biological_collection_object
  has_one :determiner, as: :role_object

end
