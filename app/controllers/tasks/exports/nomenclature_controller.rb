class Tasks::Exports::NomenclatureController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def basic
  end

  def download_basic

    redirect_to export_basic_nomenclature_path, notice: 'Nothing selected' and return unless !params[:taxon_name_id].blank?
    @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params.require(:taxon_name_id))
    download = ::Export::BasicNomenclature.download_async(@taxon_name, request.url)
    redirect_to file_download_path(download)
  end

end
