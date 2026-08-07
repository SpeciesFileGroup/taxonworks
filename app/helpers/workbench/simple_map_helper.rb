module Workbench::SimpleMapHelper

  # @param [Objects] map_objects an array of objects which know how to GeoJSON themselves
  # @param [String] map_center String of the form 'xx (f.ff f.ff)' to use as an over-ride of the maps.js center
  # calculation
  # @param [String] border_string set to 'border="1"' if the table should have borders
  def simple_map(map_objects, map_center = nil, border_string = '')
    simple_map_component(map_objects, map_center, border_string)
  end

  def simple_map_component(map_objects, map_center = nil, border_string = '')
    render(partial: 'shared/data/gis/simple_map',
           locals:  {map_objects:   map_objects,
                     map_center:    map_center,
                     border_string: border_string})
  end
end
