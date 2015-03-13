var _init_geographic_area_map;

_init_geographic_area_map = function init_geographic_area_map()         // initialization function for geographic area map
{                                                                       // also used to display geographic item
    if (document.getElementById('geographic_item_map_canvas') != null) {
        if (document.getElementById('feature_collection') != null) {
            var newfcdata = $("#feature_collection");
            var fcdata = newfcdata.data('feature-collection');

            initializeMap("geographic_item_map_canvas", fcdata);
            //add_map_listeners();
        }
    }
}
$(document).ready(_init_geographic_area_map);
$(document).on("page:load", _init_geographic_area_map);

