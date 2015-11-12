# A biological relationship defines a biological relationship type between two biological entities (e.g. specimen and specimen, otu and specimen etc.) 
#
# @!attribute name
#   @return [String]
#     the name of the relationship 
#
# @!attribute is_transitive
#   @return [Boolean]
#     whether the relationship is transitive, i.e. if A is_a B is_a C then if is_a is transitive A is_a C 
#
# @!attribute is_reflexive
#   @return [Boolean]
#     whether the relationship is reflexive, i.e. if A is_a B and is_a is_reflexive then B is_a A 
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
    t = params[:term]
    t2 = t + "%"
    t3 = "%" + t2
    BiologicalRelationship.where("(name ILIKE ?) OR (name ILIKE ?) OR (name ILIKE ?)", t,t2,t3).where(project_id: params[:project_id])
  end

end
