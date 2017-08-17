var _init_simple_map;

_init_simple_map = function init_simple_map() {
  // TODO: To be filled in later.
  // intended for use to display on a map objects which know how to GeoJSON themselves
  var simple_map_shell = $('#_simple_map_outer');
  if (simple_map_shell.length) {
    simple_map_shell.removeAttr('hidden');
    var newfcdata = $("#_simple_map_form");
    var fcdata = newfcdata.data('feature-collection');
    var map_canvas = newfcdata.data('map-canvas');
    var map_center = newfcdata.data('map-center');
    console.log("2542352542");
    var simple_map = TW.vendor.lib.google.maps.initializeMap(map_canvas, fcdata);
  }
};

$(document).on('turbolinks:load', _init_simple_map);

