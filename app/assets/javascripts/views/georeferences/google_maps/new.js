var _initialize_google_maps_georeference_widget;

_initialize_google_maps_georeference_widget = function init_new_georeference_google_map() {
  if ($('#google_maps_georeference_widget').length) {  // preempt omni-listener affecting wrong canvas
    var setup = TW.vendor.lib.google.maps.draw.initializeGoogleMapWithDrawManager("#google_maps_georeference_widget");
    var map = setup[0];
    var drawingManager = setup[1];

    // An array containing the marker itself, and the marker type
    var last = null;

    google.maps.event.addListener(drawingManager, 'overlaycomplete', function (event) {

        // Remove the last created shape if it exists.
        if (last != null) {
          if (last[0] != null) {
            TW.vendor.lib.google.maps.draw.removeItemFromMap(last[0]);
          }
        }

        last = [event.overlay, event.type];

        // Style a notice when form is ready to submit
        $("#shape_is_loaded").text('Shape (' + last[1] + ') is assigned.');
        $("#shape_is_loaded").prop('class', 'alert alert-notice');

        // Disable/enable buttons
        $("#create_georeference_button").prop('disabled', false);

        if ($("#next_without_georeference").length) {
          $("#create_and_next_georeference_button").prop('disabled', false);
        }

        // When create is clicked copy the shape data to the form, only do this on click
        // so that edited features are fully referenced and we don't have to put listeners
        // on each path.
        $("#create_georeference_button").add("#create_and_next_georeference_button").bind("click", function () {
          var feature = TW.vendor.lib.google.maps.draw.buildFeatureCollectionFromShape(last[0], last[1]);
          $("#georeference_geographic_item_attributes_shape").val(JSON.stringify(feature[0]));
        });
      }
    );

    $("#reset_georeference_map").bind("click", function () {
      TW.vendor.lib.google.maps.draw.removeItemFromMap(last[0]);
      $("#shape_is_loaded").toggleClass('alert alert-notice');
      $("#shape_is_loaded").text('');
      $("#create_georeference_button").prop('disabled', true);
      if ($("#next_without_georeference").length) {
        $("#create_and_next_georeference_button").prop('disabled', true);
      }

    });
  }
};

$(document).ready(_initialize_google_maps_georeference_widget);
$(document).on("page:load", _initialize_google_maps_georeference_widget);
