class ContainerItem < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 

  acts_as_list scope: [:container_id]
  belongs_to :container
  belongs_to :contained_object, polymorphic: true
  validates_presence_of :contained_object, :container 
end
