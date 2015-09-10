# A biological relationship type is...
#   @todo
#
# @!attribute type
#   @todo
#
# @!attribute biological_property_id
#   @todo
#
# @!attribute biological_relationship_id
#   @todo
#
# @!attribute project_id
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
