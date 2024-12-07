class Tasks::TaxonNames::SynchronizeOtusController < ApplicationController
  include TaskControllerConfiguration

  # GET/POST (hack preview)
  def index
    @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params[:taxon_name_id]) if params[:taxon_name_id]
    @taxon_name ||= sessions_current_project.root_taxon_name
  end

  # POST
  def synchronize

    @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params[:taxon_name_id])
    redirect_to synchronize_otus_to_nomenclature_task_path(taxon_name_id: @taxon_name.id), alert: "Please select a mode." and return if params[:mode].blank?
    if a = TaxonName.synchronize_otus(taxon_name_id: @taxon_name.id, mode: params.require(:mode)&.to_sym, user_id: sessions_current_user_id)
      redirect_to synchronize_otus_to_nomenclature_task_path(taxon_name_id: @taxon_name.id), notice: "Created #{a} OTUs"
    else
      redirect_to synchronize_otus_to_nomenclature_task_path, alert: 'Syncronization failed.'
    end
  end

end
