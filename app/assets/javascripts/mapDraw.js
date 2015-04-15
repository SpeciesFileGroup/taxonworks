

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

// This references nothing in the DOM!
// TODO: make more forgiving by allowing null fcdata or map_center_parts (stub blank legal values)
// in these cases draw a default map
function initializeGoogleMap(map_canvas, fcdata, map_center_parts) {

  // does this need to be set?  would it alter fcdata if not set?
  var mapData = fcdata;

  //
  // find a bounding box for the map (and a map center?)
  //
  var bounds = {};    //xminp: xmaxp: xminm: xmaxm: ymin: ymax: -90.0, center_long: center_lat: gzoom:

  var lat = map_center_parts[1].split(' ')[1];
  var lng = map_center_parts[1].split(' ')[0];

  // TODO: what does this actually do, should it be calculateCenter()?  If it is
  // setting a value for bounds then it should be assinging bounds to a function
  // that returns bounds
  getData(mapData, bounds);  // scan var data as feature collection with homebrew traverser, collecting bounds
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
  });

  map.data.addGeoJson(mapData);

  return map;
}


function initializeDrawingManger(map) {
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

  drawingManager.setMap(map);
  return drawingManager;
}

function addDrawingListeners(map, event) {
  return true;
}
