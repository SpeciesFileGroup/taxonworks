class Tasks::BiologicalAssociations::FamilySummaryController < ApplicationController
  include TaskControllerConfiguration

  def index
    @biological_associations_query = ::Queries::BiologicalAssociation::Filter.new(params)
    @biological_associations = @biological_associations_query.all.page(params[:page]).per(5000)

    @data = helpers.family_by_genus_summary(@biological_associations) 
    params[:per] = 5000
  end

end
