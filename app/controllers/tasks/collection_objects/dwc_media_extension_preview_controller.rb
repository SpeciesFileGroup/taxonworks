class Tasks::CollectionObjects::DwcMediaExtensionPreviewController < ApplicationController
  include TaskControllerConfiguration

  def index
    @collection_objects_query = ::Queries::CollectionObject::Filter.new(params)
    @collection_objects = @collection_objects_query.all
      .includes(:images, :sounds, observations: :images, taxon_determination: {otu: :taxon_name})
      .order(:id)
      .page(params[:page]).per(params[:per])
  end

end
