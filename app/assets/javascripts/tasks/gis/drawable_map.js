var _init_drawable_map;

_init_drawable_map = function init_drawable_map() {
  var gr_last = null;     // last item drawn
  var drawable_map;  // intended for use to display on a map objects which know how to GeoJSON themselves
  var drawable_map_shell = $('#_drawable_map_outer');
  if (drawable_map_shell.length) {
    drawable_map_shell.removeAttr('hidden');
    drawable_map = initializeGoogleMapWithDrawManager(_drawable_map_form);

    $(".map_toggle").click(function (event) {
      $("#area_selector").attr('hidden', true);
      $("#map_selector").removeAttr('hidden');
      $(".on_selector").removeAttr('hidden');
      $(".map_toggle").attr('hidden', true);
    });

    $(".on_selector").click(function (event) {
      $("#map_selector").attr('hidden', true);
      $("#area_selector").removeAttr('hidden');
      $(".map_toggle").removeAttr('hidden');
      $(".on_selector").attr('hidden', true);
    });

    $("send_report_params").click(function (event) {      // register the click handler for the made-from-scratch-button
      var feature = buildFeatureCollectionFromShape(gr_last[0], gr_last[1]);
      $("#drawn_area_shape").val(JSON.stringify(feature[0]));
    }
  );
  google.maps.event.addListener(drawable_map[1], 'overlaycomplete', function (event) {
      // Remove the last created shape if it exists.
      if (gr_last != null) {
        if (gr_last[0] != null) {
          removeItemFromMap(gr_last[0]);
        }
      }
      gr_last = [event.overlay, event.type];
      var feature = buildFeatureCollectionFromShape(gr_last[0], gr_last[1]);
      $("#drawn_area_shape").val(JSON.stringify(feature[0]));
    }
  );
  }
};

$(document).ready(_init_drawable_map);
$(document).on('page:load', _init_drawable_map);

