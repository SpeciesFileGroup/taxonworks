# Type material dashboard: an overview of catalog completeness for TypeMaterial,
# the links between physical CollectionObjects and species-group TaxonNames.
#
# Data are scoped by a Queries::TaxonName::Filter (defaulting to
# nomenclature_group=Species, taxon_name_type=Protonym). Data gathering and
# aggregation live in Tasks::TypeMaterials::DashboardHelper and
# Utilities::{TypeMaterial,DarwinCore}::*.
#
# @author Claude (>50% of code)
#
class Tasks::TypeMaterials::DashboardController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  # GET /tasks/type_materials/dashboard/report.json
  def report

    # q =  taxon_name_query
    # byebug
    render json: helpers.type_material_dashboard_report(
      taxon_name_query,
      sessions_current_project_id
    )
  end

  private

  def taxon_name_query
    if params[:taxon_name_query]
      params[:taxon_name_query][:nomenclature_group] = 'Species'
      params[:taxon_name_query][:taxon_name_type] = 'Protonym'
      ::Queries::TaxonName::Filter.new(params[:taxon_name_query])
    else
      params[:nomenclature_group] = 'Species'
      params[:taxon_name_type] = 'Protonym'
      ::Queries::TaxonName::Filter.new(params)
    end
  end
end
