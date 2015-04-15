var _init_georeference_google_map;      //DISPLAY/SHOW google map of georeference

_init_georeference_google_map = function init_georeference_google_map()        // initialization function for georeference google map
{
  if ($('#georeference_google_map_canvas').length) {    //preempt omni-listener affecting wrong canvas
    if ($('#feature_collection').length) {
      var newfcdata = $("#feature_collection");
      var fcdata = newfcdata.data('feature-collection');

      initializeMap("georeference_google_map_canvas", fcdata);
    }
  }
}
$(document).ready(_init_georeference_google_map);
$(document).on("page:load", _init_georeference_google_map);


var _init_new_georeference_google_map;

_init_new_georeference_google_map = function init_new_georeference_google_map() {
  if ($('#new_georeference_google_map_canvas').length) {    // preempt omni-listener affecting wrong canvas
    if ($('#feature_collection').length) {

      var newadwidget = $("#feature_collection");
      var fcdata = newadwidget.data('feature-collection');

      // Rich - the map presently fails to initialize unless there is a a legal feature collection in fcdata,
      // is this the intent?  It seems is should default to render nothing if fcdata == null?
      var map = initializeDrawItem("new_georeference_google_map_canvas", fcdata);
      var drawingManager = initializeDrawingManger(map);

      var last = null;

      google.maps.event.addListener(drawingManager, 'overlaycomplete', function (overlay) {


            //   drawingManager.setDrawingMode(null);
            //  drawingManager.setOptions({
            //   drawingControl: false
            //  });

            // Add the listeners


            if (last != null) {
              if (last[0] != null) {
                if (last[1] != 'marker' || overlay.type != 'marker') {
                  removeItemFromMap(last[0]);
                }
                ;
              }
              ;
            }
            ;

            last = [overlay.overlay, overlay.type];

            // debugging
            // var feature = buildFeatureCollectionFromShape(last[0], last[1]);
            // make a full-fledged FeatureCollection for grins
            // featureCollection.push({"type": "FeatureCollection", "features": feature})
            //  $("#geoType").text(feature[0]["geometry"]["type"])
            //  $("#geoShape").text(JSON.stringify(feature[0]));
            //  $("#georeference_geographic_item_attributes_shape").val(JSON.stringify(feature[0]));
            //$("#map_coords").html(JSON.stringify(featureCollection[0]));

            $("#shape_is_loaded").text('Shape (' + last[1] + ') is assigned.');
            $("#shape_is_loaded").prop('class', 'alert alert-notice');

            $("#create_georeference_button").prop('disabled', false);

            if ($("#next_without_georeference").length) {
              $("#create_and_next_georeference_button").prop('disabled', false);
            }

            $("#create_georeference_button").add("#create_and_next_georeference_button").bind("click", function () {
              var feature = buildFeatureCollectionFromShape(last[0], last[1]);
              $("#georeference_geographic_item_attributes_shape").val(JSON.stringify(feature[0]));
            });

          }
      );


      // add_new_draw_item_map_listeners(map);

      $("#reset_georeference_map").bind("click", function () {
        map = initializeDrawItem("new_georeference_google_map_canvas", fcdata);
        $("#shape_is_loaded").toggleClass('alert alert-notice');
        $("#shape_is_loaded").text('');
      });
    }
  }
}

$(document).ready(_init_new_georeference_google_map);
$(document).on("page:load", _init_new_georeference_google_map);
