class Tasks::CollectionObjects::BrowseController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_collection_object, only: [:index]

  # GET
  def index
    @data = ::Catalog::CollectionObject.data_for(@collection_object)
  end

  protected

  def set_collection_object
    id = params[:collection_object_id]
    id ||= CollectionObject.with_project_id(sessions_current_project_id).limit(1).pluck(:id)[0]
    redirect_to new_collection_object_path, notice: 'Create a collection object first.' and return if id.nil?
    @collection_object = CollectionObject
      .where(project_id: sessions_current_project_id)
      .preload(:identifiers, :collecting_event, depictions: [:image], taxon_determinations: [:determiners])
      .find(id)
    @collection_object.set_dwc_occurrence
  end

end
