class Tasks::CollectionObjects::DwcMediaExtensionPreviewController < ApplicationController
  include TaskControllerConfiguration

  def index
    @collection_objects_query = ::Queries::CollectionObject::Filter.new(params)
    @collection_objects = @collection_objects_query.all.order(:id).page(params[:page]).per(params[:per])
  end

end
