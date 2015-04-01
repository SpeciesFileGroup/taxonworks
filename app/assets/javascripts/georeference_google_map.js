var _init_georeference_google_map;      //DISPLAY/SHOW google map of georeference

_init_georeference_google_map = function init_georeference_google_map()        // initialization function for georeference google map
{
    if ($('#georeference_google_map_canvas').length) {    //preempt omni-listener affecting wrong canvas
        if ($('#feature_collection').length) {
            var newfcdata = $("#feature_collection");
            var fcdata = newfcdata.data('feature-collection');

            initializeMap("georeference_google_map_canvas", fcdata);
        }
    }
}
$(document).ready(_init_georeference_google_map);
$(document).on("page:load", _init_georeference_google_map);


var _init_new_georeference_google_map;

_init_new_georeference_google_map = function init_new_georeference_google_map() {
  if ($('#new_georeference_google_map_canvas').length) {    // preempt omni-listener affecting wrong canvas
    if ($('#feature_collection').length) {
      var newadwidget = $("#feature_collection");
      var fcdata = newadwidget.data('feature-collection');

      // Rich - the map presently fails to initialize unless there is a a legal feature collection in fcdata,
      // is this the intent?  It seems is should default to render nothing if fcdata == null?
      var map = initializeDrawItem("new_georeference_google_map_canvas", fcdata); 
      // add_new_draw_item_map_listeners(map);

      $( "#reset_georeference_map" ).bind( "click", function() {
        map = initializeDrawItem("new_georeference_google_map_canvas", fcdata);
      });
    }
  }
}

$(document).ready(_init_new_georeference_google_map);
$(document).on("page:load", _init_new_georeference_google_map);
