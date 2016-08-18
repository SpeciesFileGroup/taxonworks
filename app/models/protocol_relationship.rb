class ProtocolRelationship < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  acts_as_list scope: [:protocol_id]

  belongs_to :protocol
  belongs_to :protocol_relationship_object, polymorphic: true

  validates_presence_of :protocol_id
  validates_presence_of :protocol_relationship_object_id
  validates_presence_of :protocol_relationship_object_type
end
