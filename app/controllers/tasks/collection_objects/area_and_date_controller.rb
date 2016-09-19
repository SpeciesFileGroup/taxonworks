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
    @geographic_area_id = params[:geographic_area_id]
    @shape_in = params[:drawn_area_shape]

    @collection_objects = GeographicItem.gather_selected_data(@geographic_area_id, @shape_in, 'CollectionObject')
    # generate map and/or list
    # render json: {'tasks/accessions/report/dwca/table', collection_objects: @collection_objects}
    render json: {html: @collection_objects_count.to_s}
  end

  # GET
  def set_area
    @geographic_area_id = params[:geographic_area_id]
    @shape_in = params[:drawn_area_shape]
    @collection_objects_count = GeographicItem.gather_selected_data(@geographic_area_id, @shape_in, 'CollectionObject').count

    render json: {html: @collection_objects_count.to_s}
  end

  # GET
  def set_date

  end

  def download_result

  end

  def gather_data

  end

end
