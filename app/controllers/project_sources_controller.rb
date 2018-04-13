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

  def create
    @project_source = ProjectSource.new(project_source_params) 
    if @project_source.save
      @source = @project_source.source
      flash[:notice] = 'Added source to project.'
    else 
      flash[:notice] = "Failed to add source to project. #{@project_source.error_messages}."
      render source_path(@project_source.source)
    end
  end

  def destroy
    @project_source = ProjectSource.find(params[:id])
    @source = @project_source.source
    @project_source.destroy 
    render :create # same code
  end

  def autocomplete
    @sources = Queries::Source::Autocomplete.new(
      params.require(:term),
      {project_id: sessions_current_project_id, limit_to_project: true} 
    ).autocomplete

    render 'sources/autocomplete'
  end

  protected

  def project_source_params
    params.require(:project_source).permit(:source_id, :project_id)
  end

end
