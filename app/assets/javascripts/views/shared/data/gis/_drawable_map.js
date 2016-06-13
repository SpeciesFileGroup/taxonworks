var _init_drawable_map;

_init_drawable_map = function init_drawable_map() {
  var gr_last = null;     // last item drawn
  var drawable_map;  // intended for use to display on a map objects which know how to GeoJSON themselves
  var drawable_map_shell = $('#_drawable_map_outer');
  if (drawable_map_shell.length) {
    //drawable_map = initializeGoogleMapWithDrawManager(_drawable_map_form);
    //drawable_map_shell.attr('hidden', true);

    $(".map_toggle").click(function (event) {           // switch to the map
      $("#area_selector").attr('hidden', true);         // hide the area selector
      $("#map_selector").removeAttr('hidden');          // reveal the map
      $(".on_selector").removeAttr('hidden');           // expose the other link
      $(".map_toggle").attr('hidden', true);
      $("[name='[geographic_area_id]']").attr('value', '');
      drawable_map = TW.vendor.lib.google.maps.draw.initializeGoogleMapWithDrawManager(_drawable_map_form);
      google.maps.event.addListener(drawable_map[1], 'overlaycomplete', function (event) {
          // Remove the last created shape if it exists.
          if (gr_last != null) {
            if (gr_last[0] != null) {
              removeItemFromMap(gr_last[0]);
            }
          }
          gr_last = [event.overlay, event.type];
        var feature = TW.vendor.lib.google.maps.draw.buildFeatureCollectionFromShape(gr_last[0], gr_last[1]);
          $("#drawn_area_shape").val(JSON.stringify(feature[0]));
        }
      );
    });

    $(".on_selector").click(function (event) {          // switch to the area by name selector
      $("#map_selector").attr('hidden', true);          // hide the map
      $("#area_selector").removeAttr('hidden');         // reveal the area selector
      $(".map_toggle").removeAttr('hidden');            // expose the other link
      $(".on_selector").attr('hidden', true);
      $("#drawn_area_shape").attr('value', '');
    });

    $("send_report_params").click(function (event) {      // register the click handler for the made-from-scratch-button
      var feature = TW.vendor.lib.google.maps.draw.buildFeatureCollectionFromShape(gr_last[0], gr_last[1]);
        $("#drawn_area_shape").val(JSON.stringify(feature[0]));
      }
    );


  }
};

$(document).ready(_init_drawable_map);
$(document).on('page:load', _init_drawable_map);

