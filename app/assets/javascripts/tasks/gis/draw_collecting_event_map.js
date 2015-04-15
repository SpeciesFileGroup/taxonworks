var _init_collecting_event_map;

_init_collecting_event_map = function init_collecting_event_map()         // initialization function for collecting event map
{
    if (document.getElementById('collecting_event_map_canvas') != null) {
        if (document.getElementById('feature_collection') != null) {
            var newfcdata = $("#feature_collection");
            var fcdata = newfcdata.data('feature-collection');

            initializeMap("collecting_event_map_canvas", fcdata);
            //add_map_listeners();
        }
    }
}
$(document).ready(_init_collecting_event_map);
$(document).on("page:load", _init_collecting_event_map);
