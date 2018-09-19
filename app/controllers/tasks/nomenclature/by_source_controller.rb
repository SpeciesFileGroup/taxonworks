class Tasks::Nomenclature::BySourceController < ApplicationController
  include TaskControllerConfiguration

  def index
    # @source = Source.find(params[:id]) unless params[:id].blank?
    # @source ||= Project.find(sessions_current_project_id).project_sources.first.source
  end
end
