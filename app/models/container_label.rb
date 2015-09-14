# A buffer for holding specifications for physical labels of the container
#
# @!attribute label
#   @return [String]
#   @todo
#
# @!attribute date_printed
#   @return [DateTime]
#   @todo
#
# @!attribute print_style
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute container_id
#   @return [Integer]
#   @todo
#
class ContainerLabel < ActiveRecord::Base

  acts_as_list scope: [:container]

  include Housekeeping
  include Shared::IsData

  belongs_to :container

  validates_presence_of :container
  validates_presence_of :label
end
