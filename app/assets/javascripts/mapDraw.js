function buildFeatureCollectionFromShape(shape, shape_type) {

  //  var featureCollection = [];
  var feature = [];
  var coordinates = [];
  var coordList = [];
  var geometry = [];
  var overlayType = shape_type[0].toUpperCase() + shape_type.slice(1);
  var radius = undefined;

  switch (overlayType) {
    case 'Polyline':
      overlayType = 'LineString';
      break;
    case 'Marker':
      overlayType = 'Point';
      coordinates.push(shape.position);
      break;
    case 'Circle':
      overlayType = 'Point';

      coordinates.push(shape.center);
      radius = shape.radius;
      break;
  }

  if (coordinates.length == 0) {      // 0 if not a point or circle, coordinates is empty
    coordinates = shape.getPath().getArray();     // so get the array from the path

    for (var i = 0; i < coordinates.length; i++) {      // for LineString or Polygon
      geometry.push([coordinates[i].lng(), coordinates[i].lat()]);
    }

    if (overlayType == 'Polygon') {
      geometry.push([coordinates[0].lng(), coordinates[0].lat()]);
      coordList.push(geometry);
    }
    else {
      coordList = geometry;
    }

  }
  else {          // it is a circle or point
    geometry = [coordinates[0].lng(), coordinates[0].lat()];
    coordList = geometry;
  }

  feature.push({
    "type": "Feature",
    "geometry": {
      "type": overlayType,
      "coordinates": coordList
    },
    "properties": {}
  });

  // if it is a circle, the radius will be defined, so set the property
  if (radius != undefined) {
    feature[0]['properties'] = {"radius": radius};
  }

  return feature
}

function removeItemFromMap(item) {
  item.setMap(null);
}

function initializeDrawItem(map_canvas, fcdata, last) {
  var drawingManager = clearItem(drawingManager);

  var mapData = fcdata;
  var bounds = {};    //xminp: xmaxp: xminm: xmaxm: ymin: ymax: -90.0, center_long: center_lat: gzoom:

  var mcparts = $("#feature_collection").data('map-center').split("(");   // this assumes always present
  var lat = mcparts[1].split(' ')[1];
  var lng = mcparts[1].split(' ')[0];

  get_Data(mapData, bounds);               // scan var data as feature collection with homebrew traverser, collecting bounds

  var center_lat_long = get_window_center(bounds);      // compute center_lat_long from bounds and compute zoom level as gzoom

  // override computed center with verbatim center
  if (bounds.center_lat == 0 && bounds.center_long == 0) {
    center_lat_long = new google.maps.LatLng(lat, lng)
  }

  var mapOptions = {
    center: center_lat_long,
    zoom: bounds.gzoom
  };

  var map = new google.maps.Map(document.getElementById(map_canvas), mapOptions);

  map.data.setStyle({
    icon: '/assets/mapicons/mm_20_gray.png',
    fillColor: '#222222',
    strokeOpacity: 0.5,
    strokeColor: "black",
    strokeWeight: 1,
    fillOpacity: 0.2
  });                         // boundary/center work done, now actually add the data to the map

  map.data.addGeoJson(mapData);

  drawingManager.setMap(map);

  //   drawingManager.setDrawingMode(null);
  //  drawingManager.setOptions({
  //   drawingControl: false
  //  });



  // Add the listeners
  google.maps.event.addListener(drawingManager, 'overlaycomplete', function(overlay) {
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

        $("#create_georeference_button").bind("click", function() {
          var feature = buildFeatureCollectionFromShape(last[0], last[1]);
          $("#georeference_geographic_item_attributes_shape").val(JSON.stringify(feature[0]));
        });

      }
  );

  return map;
}


function clearItem() {
  var drawingManager = new google.maps.drawing.DrawingManager({
    drawingMode: google.maps.drawing.OverlayType.CIRCLE,
    drawingControl: true,
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_CENTER,
      drawingModes: [
        google.maps.drawing.OverlayType.MARKER,
        google.maps.drawing.OverlayType.CIRCLE,
        google.maps.drawing.OverlayType.POLYGON,
        google.maps.drawing.OverlayType.POLYLINE//,
        //   google.maps.drawing.OverlayType.RECTANGLE
      ]
    },
    markerOptions: {
      icon: '/assets/mapicons/mm_20_red.png',
      editable: true
    },
    circleOptions: {
      fillColor: '#66cc00',
      fillOpacity: 0.3,
      strokeWeight: 1,
      clickable: false,
      editable: true,
      zIndex: 1
    },
    polygonOptions: {
      fillColor: '#880000',
      fillOpacity: 0.3,
      editable: true,
      strokeWeight: 1,
      strokeColor: 'black'
    },
    polylineOptions: {
      fillColor: '#880000',
      fillOpacity: 0.3,
      editable: true,
      strokeWeight: 1,
      strokeColor: 'black'
    }
  });
  return drawingManager;
}

function addDrawingListeners(map, event) {
  return true;
}
