class Tasks::CollectionObjects::TableController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collection_objects = ::Queries::CollectionObject::Filter.new(params).all.order('collection_objects.id').limit(100)
  end

end
