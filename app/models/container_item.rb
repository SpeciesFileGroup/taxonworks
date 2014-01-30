class ContainerItem < ActiveRecord::Base

  include Housekeeping

  belongs_to :container
  belongs_to :contained_object, polymorphic: true

  validates_presence_of :container_id, :contained_object_id, :contained_object_type
end
