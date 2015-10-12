# A buffer for holding specifications for physical labels of the container
#
# @!attribute label
#   @return [String]
#     the physical label applied or to be applied to the drawers 
#
# @!attribute date_printed
#   @return [DateTime]
#     date the label was printed 
#
# @!attribute print_style
#   @return [String]
#     reference to a CSS class defining the style of the label
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute container_id
#   @return [Integer]
#     the container the label will be attached to 
#
class ContainerLabel < ActiveRecord::Base

  acts_as_list scope: [:container]

  include Housekeeping
  include Shared::IsData

  belongs_to :container

  validates_presence_of :container_id
  validates_presence_of :label
end
