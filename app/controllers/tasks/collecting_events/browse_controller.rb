class Tasks::CollectingEvents::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/collecting_events/browse<?collecting_event_id=123>
  def index
    assign_collecting_event
    redirect_to new_collecting_event_path, notice: 'Create a collecting event first.' and return if @collecting_event.nil?
  end

  protected

  def assign_collecting_event
    @collecting_event = CollectingEvent.where(project_id: sessions_current_project_id, id: params[:collecting_event_id]).first

    if !@collecting_event && params[:collection_object_id]
      @collecting_event = CollectionObject.where(project_id: sessions_current_project_id, id: params[:collection_object_id]).first&.collecting_event
    end

    @collecting_event ||= CollectingEvent.where(project_id: sessions_current_project_id).first
  end
  
end
