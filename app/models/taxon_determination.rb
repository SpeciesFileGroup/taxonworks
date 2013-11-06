# @!attribute otu
#   @return [Otu] 
#   the OTU (concept) behind the determination 
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

  include Shared::HasRoles
  include Shared::Citable

  belongs_to :otu
  belongs_to :biological_collection_object

  has_one :determiner_roles, class_name: 'Role::Determiner', as: :role_object
  has_one :determiner, through: :determiner_roles, source: :person

end
