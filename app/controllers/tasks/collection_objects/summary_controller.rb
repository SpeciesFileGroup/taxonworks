class Tasks::CollectionObjects::SummaryController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    set_queries
  end

  def report
    set_queries
    @target = params[:target]
  end

  private

  def set_queries
    @collection_objects_query = ::Queries::CollectionObject::Filter.new(params.merge(project_id: sessions_current_project_id))
    @collection_objects = @collection_objects_query.all
    @loans = ::Queries::Loan::Filter.new(collection_object_query: @collection_objects_query.params).all
    @images = ::Queries::Image::Filter.new(collection_object_query: @collection_objects_query.params).all
    @collecting_events = ::Queries::CollectingEvent::Filter.new(collection_object_query: @collection_objects_query.params).all
  end

end
