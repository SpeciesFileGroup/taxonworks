var TW = TW || {};
TW.vendor = TW.vendor || {};
TW.vendor.views = TW.vendor.lib || {};
TW.vendor.views.shared = TW.vendor.views.shared || {};
TW.vendor.views.shared.gis = TW.vendor.views.shared.gis || {};

Object.assign(TW.vendor.views.shared.gis, {

  init_drawable_map: function() {
    var gr_last = null;     // last item drawn
    var drawable_map;  // intended for use to display on a map objects which know how to GeoJSON themselves
      //drawable_map = initializeGoogleMapWithDrawManager(_drawable_map_form);
      //drawable_map_shell.attr('hidden', true);    

      function loadDrawableMap() {
        $("#area_selector").attr('hidden', true);         // hide the area selector
        $("#map_selector").removeAttr('hidden');          // reveal the map
        $(".on_selector").removeAttr('hidden');           // expose the other link
        $(".map_toggle").attr('hidden', true);
        $("[name='[geographic_area_id]']").attr('value', '');
        $("#geographic_area_id_for_by_area").prop('value', '');
        drawable_map = TW.vendor.lib.google.maps.draw.initializeGoogleMapWithDrawManager(_drawable_map_form);
        TW.vendor.lib.google.maps.draw.singleDrawnFeatureToMapListeners(drawable_map, gr_last, "#drawn_area_shape");
      }

      function hideDrawableMap() {
        $("#map_selector").attr('hidden', true);          // hide the map
        $("#area_selector").removeAttr('hidden');         // reveal the area selector
        $(".map_toggle").removeAttr('hidden');            // expose the other link
        $(".on_selector").attr('hidden', true);
        $("#drawn_area_shape").attr('value', '');
      }

      $("#toggle_slide_area").click(function (event) {
        if($("#toggle_slide_area").is(':checked')) {          // switch to the map
          loadDrawableMap();
        }
        else {
          hideDrawableMap();
        }
      });       

      $(".map_toggle").click(function (event) {           // switch to the map
        loadDrawableMap();
      }); 

      $(".on_selector").click(function (event) {          // switch to the area by name selector
        hideDrawableMap();
      });

      $("send_report_params").click(function (event) {      // register the click handler for the made-from-scratch-button
        var feature = TW.vendor.lib.google.maps.draw.buildFeatureCollectionFromShape(gr_last[0], gr_last[1]);
          $("#drawn_area_shape").val(JSON.stringify(feature[0]));
        }
      );
      if ($('#_drawable_map_form').data('feature-collection').features.length > 0) {
        loadDrawableMap();
      }
    
    // if (typeof $('#_drawable_map_form').data('feature-collection') === "object" &&
    //     $('#_drawable_map_form').data('feature-collection').hasOwnProperty("features") &&
    //     $('#_drawable_map_form').data('feature-collection').features.length > 0) {
    //   loadDrawableMap();
    // }
  }
});

$(document).on('turbolinks:load', function() {
  if($('#_drawable_map_outer').length) {
    TW.vendor.lib.google.maps.loadGoogleMapsAPI().then(function() {
      TW.vendor.views.shared.gis.init_drawable_map();
    })
  }
});

