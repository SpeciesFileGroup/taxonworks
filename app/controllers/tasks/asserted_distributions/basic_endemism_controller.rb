class Tasks::AssertedDistributions::BasicEndemismController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params[:taxon_name_id]) if params[:taxon_name_id].present?
    @taxon_name ||= sessions_current_project.root_taxon_name

    @shape =
     (GeographicArea.find(params[:geographic_area_id]) if
       params[:geographic_area_id].present?) ||
     (Gazetteer.find(params[:gazetteer_id]) if params[:gazetteer_id].present?) ||
      GeographicArea.first

    shape_type = @shape.kind_of?(GeographicArea) ? 'GeographicArea' : 'Gazetteer'
    @data = TaxonWorks::Analysis::AssertedDistribution::BasicEndemism
      .quick_endemism(@taxon_name, shape_type, @shape.id)
  end

end
