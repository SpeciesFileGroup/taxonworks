class Tasks::BiologicalAssociations::GraphController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def data
    @biological_associations_query = ::Queries::BiologicalAssociation::Filter.new(params)
    @biological_associations = @biological_associations_query.all.page(params[:page]).per(5000)
    params[:per] = 5000

    render json: helpers.objects_graph( @biological_associations  ).to_json

  end

end
