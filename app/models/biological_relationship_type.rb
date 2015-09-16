# A biological relationship type is...
#   @todo
#
# @!attribute type
#   @return [String]
#   @todo
#
# @!attribute biological_property_id
#   @return [Integer]
#   @todo
#
# @!attribute biological_relationship_id
#   @return [Integer]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiologicalRelationshipType < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 

  belongs_to :biological_property, inverse_of: :biological_relationship_types
  belongs_to :biological_relationship, inverse_of: :biological_relationship_types

  validates_presence_of :type
  validates :biological_property, presence: true
  validates :biological_relationship, presence: true
end
