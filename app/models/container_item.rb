# A container item is something that has been "localized to" a container.  
# We can't say that it is "in" the container, because not all containers (e.g. a pin with three specimens) contain the object.  
# By "localized to" we mean that if you can find the container, then its contents should also be locatable.  
#
# @!attribute container_id
#   @return [Integer]
#     id of the container  
#
# @!attribute position
#   @return [Integer]
#     index for acts a list, set by code 
#
# @!attribute contained_object_id
#   @return [Integer]
#     the id of the object that is contained (Rails polymorphic)
#
# @!attribute contained_object_type
#   @return [String]
#     the type of the object that is contained (Rails polymorphic)
#
# @!attribute localization
#   @return [String]
#   some additional modifier arbitrarily defining the position of this item, aka disposition, always relative to enclosing container
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

  # !! this will prevent accepts_nested assignments if we add this
  validates_presence_of :contained_object, :container 

  # @return [Scope]
  #   ContainerItems in the same immediate container as self
  def siblings
    ContainerItem.where(container_id: container_id).where.not(id: id)
  end

  # @return [Scope]
  #   All sibiling ContainerItems in this container and its nested Containers
  def all_siblings
    ContainerItem.where(container_id: Container.find(container_id).self_and_descendants.pluck(:id))
  end

  def self.find_for_autocomplete(params)
    Queries::ContainerItemAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

  # return [Boolean]
  #   whether or not this container item is in the passed container
  def contained_by?(container)
    Container.find(container_id).self_and_ancestors.pluck(:id).include?(container.id)
  end

end
