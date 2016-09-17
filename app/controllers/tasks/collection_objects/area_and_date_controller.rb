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

  # GET
  def set_area
    message = ''
    value = params['gr_geographic_item_attributes_shape']
    if value.blank?
      @georeferences = Georeference.where('false')
    else
      feature = RGeo::GeoJSON.decode(value, :json_parser => :json)
      geometry = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry = geometry.as_text
      radius = feature['radius']
      case this_type
        when 'point'
          @georeferences = Georeference.joins(:geographic_item).where(GeographicItem.within_radius_of_wkt_sql(geometry, radius))
        when 'polygon'
          @georeferences = Georeference.joins(:geographic_item).where(GeographicItem.contained_by_wkt_sql(geometry))
        else
      end
      if @georeferences.length == 0
        message = 'no objects contained in drawn shape'
      end
      render_gr_select_json(message)
    end


    @geographic_area          = GeographicArea.find(params[:geographic_area_id])
  end

  # GET
  def set_date

  end

  def download_result

  end

end
