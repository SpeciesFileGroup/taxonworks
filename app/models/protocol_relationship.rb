class ProtocolRelationship < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  acts_as_list scope: [:protocol_id]

  belongs_to :protocol, inverse_of: :protocol_relationships
  belongs_to :protocol_relationship_object, polymorphic: true

  # Do not include these validations, they will prevent nested_attributes_for from passing (see
  # incompatibility with polymorphic objects)
  # validates_presence_of :protocol_relationship_object_id, :protocol_relationship_object_type

  validates_presence_of :protocol
end
