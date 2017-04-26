class Tasks::Nomenclature::BrowseController < ApplicationController
  include TaskControllerConfiguration

  def index 
    @taxon_name = TaxonName.find(params[:id]).where(project_id: sessions_current_project_id) if !params[:id].blank?
    @taxon_name ||= Project.find(sessions_current_project_id).root_taxon_name
    @data = NomenclatureCatalog.data_for(@taxon_name)
  end

  protected

end
