class Tasks::CollectionObjects::AreaAndDateController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @list_collection_objects = CollectionObject.where(false)
    @geographic_area = GeographicArea.where(false).first
  end

  # POST
  def find
  end

  #GET
  def set_area

  end

  #GET
  def set_date

  end

end