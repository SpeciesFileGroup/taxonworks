class Tasks::CollectionObjects::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    q = CollectionObject.where(project_id: sessions_current_project_id)
    if id = params[:collection_object_id]
      @collection_object = q.find(id)
    elsif id = q.limit(1).pluck(:id).first
      redirect_to browse_collection_objects_task_path(collection_object_id: id) and return
    else
      redirect_to new_collection_object_path, notice: 'Create a collection object first.' and return
    end
  end

end
