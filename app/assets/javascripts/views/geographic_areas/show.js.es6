$(document).on("turbolinks:load",function() {
      if (document.getElementById('geographic_item_map_canvas') != null) {
        if (document.getElementById('feature_collection') != null) {
            var newfcdata = $("#feature_collection");
            var fcdata = newfcdata.data('feature-collection');

            TW.vendor.lib.google.maps.loadGoogleMapsAPI().then( resolve => {
          		TW.vendor.lib.google.maps.initializeMap("geographic_item_map_canvas", fcdata);
      		});
        }
    }
})
