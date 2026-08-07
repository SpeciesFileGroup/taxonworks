class Tasks::CollectionObjects::BrowseController < ApplicationController
  include TaskControllerConfiguration
  include PinboardItemsHelper

  # GET
  def index
    scope = CollectionObject.where(project_id: sessions_current_project_id)

    if params[:collection_object_id]
      @collection_object = scope.find(params[:collection_object_id])
    elsif pinned = inserted_pinboard_item_object_for_klass('CollectionObject')
      redirect_to browse_collection_objects_task_path(collection_object_id: pinned.id) and return
    elsif random = scope.offset(rand(scope.count)).first
      redirect_to browse_collection_objects_task_path(collection_object_id: random.id) and return
    else
      redirect_to new_collection_object_path, notice: 'Create a collection object first.' and return
    end
  end

end
