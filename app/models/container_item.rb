# A container item is something that has been "localized to" a container.  We can't say that it is "in" the container, because not all containers (e.g. a pin with three specimens) contain the object.  By "localized to" we mean that if you can find the container, then its contents should be locatable.  
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
#   some additional modifier arbitrarily defining the position of this item, aka disposition [@todo, always relative to container?!] 
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

  def self.in_container(container)
    joins(:container).where('(containers.lft >= ?) and (containers.lft <= ?) and (containers.project_id = ?)', container.lft, container.rgt, container.project_id).order('containers.lft') 
  end


end
