
//DISPLAY/SHOW google map of georeference
// initialization function for georeference google map
$(document).on("turbolinks:load", function() {

  if ($('#georeference_google_map_canvas').length) {    //preempt omni-listener affecting wrong canvas
    if ($('#feature_collection').length) {
      var newfcdata = $("#feature_collection");
      var fcdata = newfcdata.data('feature-collection');
      TW.vendor.lib.google.maps.loadGoogleMapsAPI().then( resolve => {
        TW.vendor.lib.google.maps.initializeMap("georeference_google_map_canvas", fcdata);
  	  });
    }
  }
})

