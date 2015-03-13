var _init_georeference_google_map;      //DISPLAY/SHOW google map of georeference

_init_georeference_google_map = function init_georeference_google_map()        // initialization function for georeference google map
{
    if (document.getElementById('georeference_google_map_canvas') != null) {    //preempt omni-listener affecting wrong canvas
        if (document.getElementById('feature_collection') != null) {
            var newfcdata = $("#feature_collection");
            var fcdata = newfcdata.data('feature-collection');

            initializeMap("georeference_google_map_canvas", fcdata);
            //add_map_listeners();
        }
    }
}
$(document).ready(_init_georeference_google_map);
$(document).on("page:load", _init_georeference_google_map);


var _init_new_georeference_google_map;

_init_new_georeference_google_map = function init_new_georeference_google_map() {
    if (document.getElementById('new_georeference_google_map_canvas') != null) {    //preempt omni-listener affecting wrong canvas
        if (document.getElementById('feature_collection') != null) {
            var newadwidget = $("#feature_collection");
            var fcdata = newadwidget.data('feature-collection');
//    alert(fcdata);
            var map = initializeDrawItem("new_georeference_google_map_canvas", fcdata); // fcdata
            //add_new_draw_item_map_listeners(map);
        }
    }
}

$(document).ready(_init_new_georeference_google_map);
$(document).on("page:load", _init_new_georeference_google_map);
