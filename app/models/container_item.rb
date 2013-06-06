class ContainerItem < ActiveRecord::Base
  belongs_to :container
  belongs_to :containable, polymorphic: true

  validates_presence_of :container_id, :containable_id, :containable_type
end
