class Tasks::CollectionObjects::OutdatedNamesController < ApplicationController
  include TaskControllerConfiguration

  def index

    @collection_objects = ::Queries::CollectionObject::Filter.new(params).all
    .order('collection_objects.id')
    .page(params[:page])
    .per(params[:per])

  end

end
