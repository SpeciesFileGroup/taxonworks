class Tasks::Gis::DrawableMapController < ApplicationController
  include TaskControllerConfiguration

  def drawn_area_select
    message = ''
    value   = params['drawn_map_shape']
    finding = params['selection_object']
    if value.blank?
      case finding
        when 'collection_object'
          @collection_objects = CollectionObject.where('false')
        else
      end
    else
      feature   = RGeo::GeoJSON.decode(value, json_parser: :json)
      # isolate the WKT
      geometry  = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry  = geometry.as_text
      radius    = feature['radius']
      case finding
        when 'collection_object'
          case this_type
            when 'point'
              @collection_objects = Georeference.with_project_id(sessions_current_project_id)
                                        .joins(:geographic_item)
                                        .where(GeographicItem.within_radius_of_wkt_sql(geometry, radius))
            when 'polygon'
              @collection_objects = Georeference.with_project_id(sessions_current_project_id)
                                        .joins(:geographic_item)
                                        .where(GeographicItem.contained_by_wkt_sql(geometry))
            else
          end
        else
      end
    end
    if @collection_objects.blank?
      message = 'no objects contained in drawn shape'
    end
    render_gr_select_json(message)
  end

end
