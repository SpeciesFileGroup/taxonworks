class Tasks::Nomenclature::BySourceController < ApplicationController
  include TaskControllerConfiguration

  def index

    if !ProjectSource.where(project_id: sessions_current_project_id).any?
      flash[:notice] = 'Create or add a source to your project first.'
      redirect_to sources_path and return
    end

    @source = Source.find(params[:id]) if !params[:id].blank?
    @source ||= Project.find(sessions_current_project_id).project_sources.first.source
  end
end
