class Tasks::CollectionObjects::AreaAndDateController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @geographic_areas   = GeographicArea.where('false')
    @collection_objects = CollectionObject.where('false')
    # @collection_objects = CollectionObject.limit(3)
  end

  # POST
  # find all of the objects within the supplied area and within the supplied data range
  def find
    @collection_objects = CollectionObject.where('false')
  end

  # POST
  def set_area
    @geographic_area          = GeographicArea.find(params[:geographic_area_id])
    @collection_objects_count = 3
  end

  # GET
  def set_date

  end

  def download_result

  end

end
