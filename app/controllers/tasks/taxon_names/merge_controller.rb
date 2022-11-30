class Tasks::TaxonNames::MergeController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # GET
  def report
    @from_taxon_name = TaxonName.where(project_id: sessions_current_project_id, id: params[:from_taxon_name_id]).first
    @to_taxon_name = TaxonName.where(project_id: sessions_current_project_id, id: params[:to_taxon_name_id]).first
  end

  # POST
  def merge
    @from_taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params.require(:from_taxon_name_id))
    @to_taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params.require(:to_taxon_name_id))
    @result = @from_taxon_name.merge_to(@to_taxon_name, params.require(:kind).to_sym)

    render 'report', status: :ok and return
  end

end
