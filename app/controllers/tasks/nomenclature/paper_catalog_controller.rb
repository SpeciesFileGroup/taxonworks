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

    c = @taxon_name.descendants.that_is_valid.count
    if c > 5000
      redirect_to :index, message: "Export of #{c} is too presently too large." and return
    end

    @data = helpers.recursive_catalog_tag(@taxon_name)

    # TODO: move logic out
    if params[:submit] == 'Download'
      s = render_to_string(partial: '/tasks/nomenclature/paper_catalog/preview', locals: {taxon_name: @taxon_name, data: @data }, layout: false, formats: [:html])
      a = ::Export::PaperCatalog.export(@taxon_name, s)
      send_data(File.read(a), filename: "#{@taxon_name.name}_paper_catalog_#{DateTime.now}.zip", type: 'application/zip') and return
    end

    render :index
  end

end
