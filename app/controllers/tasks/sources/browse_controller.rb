class Tasks::Sources::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @sources = []
  end

  # GET
  def find
    @terms = params[:terms] 
    @sources = Queries::Source::Filter.new(@terms, project_id: sessions_current_project_id ).all
    render :index
  end
end
