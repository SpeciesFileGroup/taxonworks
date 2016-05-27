class ProjectSourcesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  # GET /project_sources
  def index
    @recent_objects =  Source.joins(:project_sources).where(project_sources: {project_id: sessions_current_project_id}).updated_in_last(1.month).limit(10)
    render '/shared/data/all/index'
  end

  def list
    @sources = Source.joins(:project_sources).where(project_sources: {project_id: sessions_current_project_id}).page(params[:page])
    render '/sources/list'
  end

  def autocomplete
   @sources =  Queries::SourceAutocompleteQuery.new(params[:term], project_id: sessions_current_project_id).by_project_all
    data     = @sources.collect do |t|
      {id:              t.id,
       label:           ApplicationController.helpers.source_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:      ApplicationController.helpers.source_tag(t)
      }
    end
    render :json => data
  end


end
