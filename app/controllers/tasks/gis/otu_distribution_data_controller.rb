class Tasks::Gis::OtuDistributionDataController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/gis/otu_distribution_data?otu_id|taxon_name_id=123 
  def show
    @distribution = []
    if params[:otu_id]
      @otu = Otu.where(project_id: sessions_current_project_id).find(params[:otu_id])
    elsif params[:taxon_name_id]
      @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params[:taxon_name_id])
    else
      @otu = Otu.where(project_id: sessions_current_project_id).first     
    end

    if @otu
      @distribution = Distribution.new(
        otus: Otu.where(id: @otu.id).where(project_id: sessions_current_project_id).page(params[:page])
      )
    elsif @taxon_name
      @distribution = Distribution.new(
        otus: Otu.for_taxon_name(@taxon_name).where(project_id: sessions_current_project_id).page(params[:page]).per(20)
      )
    else
      @distribution = []
    end
  end
end
