class Tasks::Nomenclature::PaperCatalogController < ApplicationController
  include TaskControllerConfiguration
  
  # GET /tasks/nomenclature/paper_catalog?taxon_name_id=123
  def index
    if params[:taxon_name_id]
      @taxon_name = Protonym.where(project_id: sessions_current_project_id).find(params[:taxon_name_id])
    else
      @taxon_name = nil
    end
  end
  
  def preview
    @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params[:taxon_name_id])
    @body, @sources = helpers.recursive_catalog_tag(@taxon_name)

    byebug

    if params[:submit] == 'Download'
      s = render_to_string(partial: '/tasks/nomenclature/paper_catalog/preview', layout: false, formats: [:html])
      send_data(s, filename: "#{taxon_name.name}_catalog_#{DateTime.now}.xml", type: 'text/plain') and return
    end
    
    
  end
  
end
