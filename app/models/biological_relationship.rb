# A biological relationship is...
#   @todo
#
# @!attribute name
#   @return [String]
#   @todo
#
# @!attribute is_transitive
#   @return [Boolean]
#   @todo
#
# @!attribute is_reflexive
#   @return [Boolean]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiologicalRelationship < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 

  validates_presence_of :name
  has_many :biological_relationship_types, inverse_of: :biological_relationship
  has_many :biological_associations, inverse_of: :biological_relationship
  has_many :biological_properties, through: :biological_relationship_types

  def self.find_for_autocomplete(params)
    Queries::BiologicalRelationshipAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

end
