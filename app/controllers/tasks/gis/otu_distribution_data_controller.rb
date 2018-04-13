class Tasks::Gis::OtuDistributionDataController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/gis/otu_distribution_data(/:id)(.:format)  
  def show
    id = params[:id]
    if id.blank?
      @otu = Otu.where(project_id: sessions_current_project_id).first
    else
      @otu = Otu.where(project_id: sessions_current_project_id).find(id)
    end

    @distribution = Distribution.new(
      otus: Otu.where(id: @otu.id).where(project_id: sessions_current_project_id).page(params[:page])
    )
    @type_tag = 'Otu'
  end

  def show_for_taxon_name
    @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params[:id])
    @distribution = Distribution.new(
      otus: Otu.for_taxon_name(@taxon_name).where(project_id: sessions_current_project_id).page(params[:page]).per(10)
    )
    @type_tag = 'Taxon name'
    
    render :show
  end

end
