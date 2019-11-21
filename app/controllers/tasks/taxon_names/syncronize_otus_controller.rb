class Tasks::TaxonNames::SyncronizeOtusController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index

  end

  def syncronize
    @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params[:taxon_name_id])
    if TaxonName.syncronize_otus(taxon_name_id: @taxon_name.id, mode: params.require[:mode])
      redirect_to syncronize_nomenclature_to_otus_task_path(taxon_name_id: @taxon_name.id)
    else
      redirect_to syncronize_nomenclature_to_otus_task_path, notice: 'Syncronization failed.'
    end
  end

end
