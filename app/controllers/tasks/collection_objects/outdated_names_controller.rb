class Tasks::CollectionObjects::OutdatedNamesController < ApplicationController
  include TaskControllerConfiguration

  def index
    @collection_objects_query = ::Queries::CollectionObject::Filter.new(params)
    @collection_objects = @collection_objects_query.all
    .order('collection_objects.id')
    .page(params[:page])
    .per(10)
  end

end
