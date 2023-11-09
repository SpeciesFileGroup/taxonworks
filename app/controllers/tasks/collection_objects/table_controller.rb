class Tasks::CollectionObjects::TableController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collection_objects_query = ::Queries::CollectionObject::Filter.new(params)
    @collection_objects = @collection_objects_query.all.order('collection_objects.id').limit(100)
  end

end
