module Workbench::SimpleMapHelper

  def simple_map(map_objects)
    render(partial: 'layouts/map_header')
      # render(partial: 'shared/data/gis/simple_map',
      #        locals:  {map_objects: map_objects})
      # fail
  end

end
