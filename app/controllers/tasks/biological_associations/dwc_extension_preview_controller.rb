class Tasks::BiologicalAssociations::DwcExtensionPreviewController < ApplicationController
  include TaskControllerConfiguration

  def index
    @biological_associations_query = ::Queries::BiologicalAssociation::Filter.new(params)
    @biological_associations = @biological_associations_query.all.page(params[:page]).per(params[:per])
  end

end
