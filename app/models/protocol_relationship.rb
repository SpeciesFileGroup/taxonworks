class ProtocolRelationship < ApplicationRecord
  include Housekeeping
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:protocol_relationship_object)

  acts_as_list scope: [:protocol_id, :project_id]

  belongs_to :protocol, inverse_of: :protocol_relationships

  # Do not include these validations, they will prevent nested_attributes_for from passing (see
  # incompatibility with polymorphic objects)
  # validates_presence_of :protocol_relationship_object_id, :protocol_relationship_object_type

  validates_presence_of :protocol_id
end
