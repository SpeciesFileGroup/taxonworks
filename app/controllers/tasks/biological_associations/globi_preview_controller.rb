class Tasks::BiologicalAssociations::GlobiPreviewController < ApplicationController
  include TaskControllerConfiguration

  def index
    @biological_associations_query = ::Queries::BiologicalAssociation::Filter.new(params)
    @biological_associations = @biological_associations_query.all.page(params[:page]).per(5000)
    params[:per] = 5000
  end

end
