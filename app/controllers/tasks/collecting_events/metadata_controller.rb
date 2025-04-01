class Tasks::CollectingEvents::MetadataController < ApplicationController
  include TaskControllerConfiguration

  def index
    redirect_to :filter_collecting_events_task, message: 'Filter a result set first.' and return if params[:collecting_event_query].blank?
    @collecting_event_query = ::Queries::CollectingEvent::Filter.new( params[:collecting_event_query] )
    @collecting_events =  @collecting_event_query.all
  end

end
