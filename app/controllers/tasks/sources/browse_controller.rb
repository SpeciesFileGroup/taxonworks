class Tasks::Sources::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @sources = []
  end

  # GET
  def find
    @terms = params[:query_term] 
    @sources = Queries::Source::Filter.new(filter_params).all.limit(500).distinct
    render :index
  end

  def filter_params
    params.permit(:query_term).merge(project_id: sessions_current_project_id)
  end
end
