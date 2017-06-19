var _init_drawable_map;

_init_drawable_map = function init_drawable_map() {
  var gr_last = null;     // last item drawn
  var drawable_map;  // intended for use to display on a map objects which know how to GeoJSON themselves
  var drawable_map_shell = $('#_drawable_map_outer');
  if (drawable_map_shell.length) {
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
      google.maps.event.addListener(drawable_map[1], 'overlaycomplete', function (event) {
          // Remove the last created shape if it exists.
          if (gr_last != null) {
            if (gr_last[0] != null) {
              TW.vendor.lib.google.maps.draw.removeItemFromMap(gr_last[0]);
            }
          }
          gr_last = [event.overlay, event.type];
        var feature = TW.vendor.lib.google.maps.draw.buildFeatureCollectionFromShape(gr_last[0], gr_last[1]);
          $("#drawn_area_shape").val(JSON.stringify(feature[0]));
        }
      );
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
  }
  // if (typeof $('#_drawable_map_form').data('feature-collection') === "object" &&
  //     $('#_drawable_map_form').data('feature-collection').hasOwnProperty("features") &&
  //     $('#_drawable_map_form').data('feature-collection').features.length > 0) {
  //   loadDrawableMap();
  // }
};

$(document).ready(_init_drawable_map);
$(document).on('page:load', _init_drawable_map);

