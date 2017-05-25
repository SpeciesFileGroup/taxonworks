class Tasks::CollectionObjects::BrowseController < ApplicationController
  include TaskControllerConfiguration

  before_filter :set_collection_object, only: [:index]
  
  # GET
  def index
    @data = CollectionObjectCatalog.data_for(@collection_object)
  end

  protected

  def set_collection_object
    id = params[:id]
    id ||= CollectionObject.with_project_id(sessions_current_project_id).limit(1).pluck(:id)[0]
    redirect_to new_collection_object_path, notice: 'Create a collection object first.' and return if id.nil? 
    @collection_object = CollectionObject.with_project_id(sessions_current_project_id).includes(:identifiers, :collecting_event, depictions: [:image], taxon_determinations: [:determiners]).find(id)
  end

end
