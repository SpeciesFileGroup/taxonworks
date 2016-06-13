var _init_georeference_google_map;      //DISPLAY/SHOW google map of georeference

_init_georeference_google_map = function init_georeference_google_map()        // initialization function for georeference google map
{
  if ($('#georeference_google_map_canvas').length) {    //preempt omni-listener affecting wrong canvas
    if ($('#feature_collection').length) {
      var newfcdata = $("#feature_collection");
      var fcdata = newfcdata.data('feature-collection');

      TW.vendor.lib.google.maps.initializeMap("georeference_google_map_canvas", fcdata);
    }
  }
};

$(document).ready(_init_georeference_google_map);
$(document).on("page:load", _init_georeference_google_map);

