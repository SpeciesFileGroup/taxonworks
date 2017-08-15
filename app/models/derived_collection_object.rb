# A derived collect object is...
#   @todo
#
# @!attribute collection_object_observation_id
#   @return [Integer]
#   @todo
#
# @!attribute collection_object_id
#   @return [Integer]
#   @todo
#
# @!attribute position
#   @return [Integer]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class DerivedCollectionObject < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  acts_as_list scope: [:project_id, :collection_object_observation_id]

  belongs_to :collection_object, inverse_of: :derived_collection_objects
  belongs_to :collection_object_observation, inverse_of: :derived_collection_objects

  validates_presence_of :collection_object_id
  validates_presence_of :collection_object_observation_id
  validates_uniqueness_of :collection_object_id, scope: [ :collection_object_observation_id ]

end
