var _init_georeference_map_widget;

_init_georeference_map_widget = function init_georeference_map()         // initialization function for collecting event map
{
    if ($("#_draw_gr_form").attr("hidden") != "hidden") {
        if ($("#georeference_map_canvas").length) {
            if (document.getElementById('feature_collection') != null) {
                var newfcdata = $("#feature_collection");
                var fcdata = newfcdata.data('feature-collection');

                initializeMap("georeference_map_canvas", fcdata);
                //add_map_listeners();
            }
        }
    }
}
$(document).ready(_init_georeference_map_widget);
$(document).on("page:load", _init_georeference_map_widget);

