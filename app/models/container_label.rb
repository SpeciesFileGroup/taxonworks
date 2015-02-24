# A buffer for holding specifications for physical labels of the container
#
class ContainerLabel < ActiveRecord::Base

  acts_as_list scope: [:container]

  include Housekeeping
  include Shared::IsData 

  belongs_to :container

  validates_presence_of :container
  validates_presence_of :label
end
