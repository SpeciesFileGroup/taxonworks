# A container item is...
#   @todo
#
# @!attribute container_id
#   @return [Integer]
#   @todo
#
# @!attribute position
#   @return [Integer]
#   @todo
#
# @!attribute contained_object_id
#   @return [Integer]
#   @todo
#
# @!attribute contained_object_type
#   @return [String]
#   @todo
#
# @!attribute localization
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class ContainerItem < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 

  acts_as_list scope: [:container_id]
  belongs_to :container
  belongs_to :contained_object, polymorphic: true
  validates_presence_of :contained_object, :container

  def self.find_for_autocomplete(params)
    Queries::ContainerItemAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

end
