class ProtocolRelationship < ApplicationRecord
  include Housekeeping
  include Shared::PolymorphicAnnotator
  include Shared::IsData

  polymorphic_annotates(:protocol_relationship_object)

  acts_as_list scope: [:protocol_id, :project_id]

  belongs_to :protocol, inverse_of: :protocol_relationships

  validates :protocol, presence: true

end
