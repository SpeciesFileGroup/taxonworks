var _init_drawable_map;

_init_drawable_map = function init_drawable_map() {
  // TODO: To be filled in later.
  // intended for use to display on a map objects which know how to GeoJSON themselves
  var drawable_map_shell = $('#_drawable_map_outer');
  if (drawable_map_shell.length) {
    drawable_map_shell.removeAttr('hidden');
    var drawable_map = initializeGoogleMapWithDrawManager(_drawable_map_form);
  }
};

$(document).ready(_init_drawable_map);
$(document).on('page:load', _init_drawable_map);

