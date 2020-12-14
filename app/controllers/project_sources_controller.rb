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

    respond_to do |format|
      if @project_source.save
        @source = @project_source.source
        format.html { flash[:notice] = 'Added source to project.' }
        format.json { render action: 'show', status: :created, location: @project_source }
        format.js { }
      else
        format.html {
          flash[:notice] = "Failed to add source to project. #{@project_source.error_messages}."
          render source_path(@project_source.source)
        }
        format.json { render json: @project_source.errors, status: :unprocessable_entity }
        format.js { }
      end
    end
  end

  def destroy
    @project_source = ProjectSource.find(params[:id])
    @source = @project_source.source # Why needed?

    respond_to do |format|
      if @project_source.destroy
        format.html { redirect_to sources_url }
        format.json { head :no_content }
        format.js { render :create } # TODO: remove?
      else
        format.html {
          flash[:notice] = @project_source.error_messages.join('; ')
          render source_path(@project_source.source)
        }
        format.json { render json: @project_source.errors, status: :unprocessable_entity }
        format.js { } # TODO: remove
      end
    end
  end

  def autocomplete
    @sources = Queries::Source::Autocomplete.new(
      params.require(:term),
      {project_id: sessions_current_project_id, limit_to_project: true}
    ).autocomplete

    render 'sources/autocomplete'
  end

  # GET /project_sources/download
  def download
    send_data Export::Download.generate_csv(
      ProjectSource.where(project_id: sessions_current_project_id)), type: 'text', filename: "project_sources_#{DateTime.now}.csv"
  end

  protected

  def project_source_params
    params.require(:project_source).permit(:source_id, :project_id)
  end

end
