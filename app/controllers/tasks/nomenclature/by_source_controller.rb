class Tasks::Nomenclature::BySourceController < ApplicationController
  include TaskControllerConfiguration

  def index 
    @source = Source.find(params[:id]) if !params[:id].blank?
    @source ||= Project.find(sessions_current_project_id).project_sources.first.source
    # @data = NomenclatureCatalog.data_for(@taxon_name)
  end

  protected

end
