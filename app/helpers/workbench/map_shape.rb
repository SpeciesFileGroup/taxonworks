  module Workbench::MapShape
    def map_shape(params)
      content_tag(:div, '', data: { 
        'map-shape' => true,
        'geojson-object' => params[:geojson_object], 
        'geojson-string' => params[:geojson_string], 
      })
    end
end