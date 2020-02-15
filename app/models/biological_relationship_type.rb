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
class BiologicalRelationshipType < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  belongs_to :biological_property, inverse_of: :biological_relationship_types
  belongs_to :biological_relationship, inverse_of: :biological_relationship_types

  validates_presence_of :type
  validates :biological_property, presence: true
  validates :biological_relationship, presence: true
end


Dir[Rails.root.to_s + '/app/models/biological_relationship_type/**/*.rb'].each { |file| require_dependency file }

