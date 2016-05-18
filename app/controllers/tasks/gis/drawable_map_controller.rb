class Tasks::Gis::DrawableMapController < ApplicationController
  include TaskControllerConfiguration

  def drawn_area_select
    message = ''
    value   = params['drawn_map_shape']
    if value.blank?
      @georeferences = Georeference.where('false')
    else
      feature   = RGeo::GeoJSON.decode(value, :json_parser => :json)
      # isolate the WKT
      geometry  = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry  = geometry.as_text
      radius    = feature['radius']
      case this_type
        when 'point'
          @georeferences = Georeference.joins(:geographic_item).where(GeographicItem.within_radius_of_wkt_sql(geometry, radius))
        when 'polygon'
          @georeferences = Georeference.joins(:geographic_item).where(GeographicItem.contained_by_wkt_sql(geometry))
        else
      end
    end
    if @georeferences.length == 0
      message = 'no objects contained in drawn shape'
    end
    render_gr_select_json(message)
  end

end
