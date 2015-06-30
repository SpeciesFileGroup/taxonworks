/* Basic library to parse through TW returned geoJSON and draw a FeatureCollection on a Google Map.
 */

var initializeMap;

initializeMap = function(canvas, feature_collection) {
  var myOptions = {
    zoom: 1,
    center: {lat: 0, lng: 0}, //center_lat_long, set to 0,0
    mapTypeControl: true,
    mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
    navigationControl: true,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };

  var map = initialize_map(canvas, myOptions);
  var data = feature_collection;

  map.data.setStyle({
      icon: '/assets/mapicons/mm_20_gray.png',
      fillColor: '#440000',
      strokeOpacity: 0.5,
      strokeColor: "black",
      strokeWeight: 1,
      fillOpacity: 0.2/*,

      fillColor: '#440000',
    strokeOpacity: 0.5,
    strokeColor: "black",
    strokeWeight: 1,
    fillOpacity: 0.3*/
  });
  if (data != undefined) { if (data["type"] = "FeatureCollection") {map.data.addGeoJson(data)}};  // put data on the map if present


// bounds for calculating center point
  var bounds = {};    //xminp: xmaxp: xminm: xmaxm: ymin: ymax: -90.0, center_long: center_lat: gzoom:
  getData(data, bounds);               // scan var data as feature collection with homebrew traverser, collecting bounds
  var center_lat_long = get_window_center(bounds);      // compute center_lat_long from bounds and compute zoom level as gzoom
 // $("#map_coords").html('Center: \xA0 \xA0 \xA0 \xA0Latitude = ' + bounds.center_lat.toFixed(6) + ' , Longitude = ' + bounds.center_long.toFixed(6));
  map.setCenter(center_lat_long);
  map.setZoom(bounds.gzoom);

  map.data.setStyle(function (feature) {
    var color = '#440000';  // dimmer red as default feature color
    if (feature.getProperty('isColorful')) {        // isColorful property signals this area/feature was clicked
      color = feature.getProperty('fillColor');   //
    }
    return /** @type {google.maps.Data.StyleOptions} */({
        icon: '/assets/mapicons/mm_20_red.png',
      fillColor: color,
      strokeColor: "black",
      strokeWeight: 1
    });
  });
  return map;             // now no global map object, use this object to add listeners to THIS map
};

function initialize_map(canvas, options) {
  var map = new google.maps.Map(document.getElementById(canvas), options);
  return map;
}


function get_window_center(bounds) {      // for use with home-brew geoJSON scanner/enumerator
  var xminp = bounds.xminp;
  var xmaxp = bounds.xmaxp;
  var xminm = bounds.xminm;
  var xmaxm = bounds.xmaxm;

  var ymin = bounds.ymin;
  var ymax = bounds.ymax;

  var center_long = bounds.center_long;
  var center_lat = bounds.center_lat;
  var gzoom = bounds.gzoom;

  if (center_long == undefined) {
    //determine case of area extent
    center_long = 0.0;
    var wm = 0.0;        // western hemisphere default area width
    var wp = 0.0;        // eastern hemisphere default area width
    if ((xminp == 180.0) && (xmaxp == 0.0)) {    //if no points, null out the range for this hemisphere
      xminp = 0.0;
    }
    if ((xmaxm == -180.0) && (xminm == 0.0)) {    //if no points, null out the range for this hemisphere
      xmaxm = 0.0;
    }
    // case of singleton poiint in either hemisphere not well treated below
    wm = xmaxm - xminm;    // width of western area, if present
    wp = xmaxp - xminp;    // width of eastern area, if present
    var xmm = xminm + 0.5 * wm;     // midpoint of west
    var xmp = xminp + 0.5 * wp;     // midpoint of east
    var wx = wm + wp;                               // total width of "contiguous" area
    center_long = xmm + xmp;    //as signed, unless overlaps +/-180
    if (wm > wp) {                // serious cheat: pick mean longitude of wider group
      center_long = xmm;       // "works" since there are so few cases that span
    }                           // the Antimeridian
    if (wm < wp) {
      center_long = xmp
    }
  }
  ;
  if (center_lat == undefined) {
    if ((ymax == -90) && (ymin == 90)) {
      ymax = 90.0;
      ymin = -90.0;
    }      // no data, so set whole earth limits
    var wy = ymax - ymin;
    center_lat = 0.5 * (ymax + ymin);
    if (Math.abs(center_lat) > 1.0) {        // if vertical center very close to equator
      var cutoff = 65.0;
      if (/*Math.abs(center_lat) > 45.0 &&*/ (ymax > cutoff || ymin < -cutoff)) {
        var angle = ymax - cutoff;
        if (center_lat < 0) {
          angle = ymin + cutoff;
        }
        var offset = Math.cos((angle /*- center_lat*/) / (180.0 / 3.1415926535));
        offset = 0.1 * (ymax - ymin) / offset;
        center_lat = center_lat + offset;
      }
      ;
    }
    ;
  }
  ;
  var sw = new google.maps.LatLng(ymin, xmm);
  var ne = new google.maps.LatLng(ymax, xmp);
  var box = new google.maps.LatLngBounds(sw, ne);
  if (wy > 0.5 * wx) {                              ///// this looks wrong or wx is wrong JRF 04MAY2015
    wx = wy * 2.0
  }       // VERY crude proportionality adjustment
  if (wx <= 0.1) {
    gzoom = 11
  }
  ;
  if (wx > 0.1) {
    gzoom = 10
  }
  ;             // quick and dirty zoom range based on size
  if (wx > 0.2) {
    gzoom = 9
  }
  ;
  if (wx > 0.5) {
    gzoom = 8
  }
  ;
  if (wx > 1.0) {
    gzoom = 7
  }
  ;
  if (wx > 2.5) {
    gzoom = 6
  }
  ;
  if (wx > 5.0) {
    gzoom = 5
  }
  ;
  if (wx > 10.0) {
    gzoom = 4
  }
  ;
  if (wx > 40.0) {
    gzoom = 3
  }
  ;
  if (wx > 80.0) {
    gzoom = 2
  }
  ;
  if (wx > 160.0/* || (wx + wy) == 0*/) {  // amended to not focus on whole earth on latter condition (single point???)
    gzoom = 1                               // wait for exceptional case to revert or rewrite condition
  }
  ;
  bounds.center_lat = center_lat;
  bounds.center_long = center_long;
  bounds.gzoom = gzoom;
  bounds.box = box;
  return new google.maps.LatLng(center_lat, center_long); /* DO NOT place comments between code center_lat_long =*/
};

// bounds for calculating center point
// divide longitude checks by hemisphere
// variables below used by stripped-down getData to compute bounds
// used to clear previous history
// so that center is recalculated
function reset_center_and_bounds(bounds) {
  bounds.center_long = undefined;
  bounds.center_lat = undefined;

  bounds.xminp = 180.0;       // use 0
  bounds.xmaxp = 0.0;        // to
  bounds.xminm = 0.0;       // +/-180-based
  bounds.xmaxm = -180.0;   // coordinates for longitude

  bounds.ymin = 90.0;    // +/-90 for latitude
  bounds.ymax = -90.0;

  bounds.gzoom = 1;   // default zoom to whole earth
  bounds.box = new google.maps.LatLngBounds(new google.maps.LatLng(bounds.ymax, bounds.xmaxm), new google.maps.LatLng(bounds.ymin, bounds.xminp));
}

// this is the scanner version; no google objects are created
function getData(feature_collection_data, bounds) {
  reset_center_and_bounds(bounds);

  // TODO: is this doing two things? What is the code after the above doing, altering the content of feature_collection_data

  // ?! does this actually affect/return anything?!
  //	get data object encoded as geoJSON (deprecated: and disseminate to google (deprecated: and leaflet arrays))
  var data = feature_collection_data;
  if (typeof (data) != "undefined") {
    var dataArray = [];
    if (data instanceof Array) {
    }       // if already an array, then do nothing
    else    // convert it to an array
    {
      dataArray[0] = data;
      data = [];
      data[0] = dataArray[0];
    }
    ;
    for (var i = 0; i < data.length; i++) {
      if (typeof (data[i].type) != "undefined") {
        if (data[i].type == "FeatureCollection") {
          for (var j = 0; j < data[i].features.length; j++) {
            //getFeature(data[i].features[j]);
            getFeature(data[i].features[j], bounds);  //getTypeData(data[i].features[j].geometry);
          }
        }
        if (data[i].type == "GeometryCollection") {
          for (var j = 0; j < data[i].geometries.length; j++) {
            getTypeData(data[i].geometries[j], bounds);
          }
          ;
        }
        else {
          getTypeData(data[i], bounds);
        }
        ;  //data[i].type
      }
      ;     //data[i] != undefined
    }
    ;        // for i
  }
  ;           //data != undefined
};              //getData

function getFeature(thisFeature, bounds) {
  if(thisFeature.type == "FeatureCollection") {
    getTypeData(thisFeature, bounds);   // if it requires recursion on FC
  }
  else {
    getTypeData(thisFeature.geometry, bounds);
  }
}

function getTypeData(thisType, bounds) {        // this version does not create google objects

  if (thisType.type == "FeatureCollection") {
    for (var i = 0; i < thisType.features.length; i++) {
      if (typeof (thisType.features[i].type) != "undefined") {
        getFeature(thisType.features[i], bounds);		//  recurse if FeatureCollection
      }
      ;     //thisType != undefined
    }
    ;        //for i
    return
  }
  ;

  if (thisType.type == "GeometryCollection") {
    for (var i = 0; i < thisType.geometries.length; i++) {
      if (typeof (thisType.geometries[i].type) != "undefined") {
        getTypeData(thisType.geometries[i], bounds);		//  recurse if GeometryCollection
      }
      ;     //thisType != undefined
    }
    ;       //for i
  }
  ;

  if (thisType.type == "Point") {
    xgtlt(bounds, thisType.coordinates[0]);
    ygtlt(bounds, thisType.coordinates[1]); //box check
  }
  ;

  if (thisType.type == "MultiPoint") {
    for (var l = 0; l < thisType.coordinates.length; l++) {
      xgtlt(bounds, thisType.coordinates[l][0]);
      ygtlt(bounds, thisType.coordinates[l][1]); //box check
    }
    ;
  }
  ;

  if (thisType.type == "LineString") {
    for (var l = 0; l < thisType.coordinates.length; l++) {
      xgtlt(bounds, thisType.coordinates[l][0]);
      ygtlt(bounds, thisType.coordinates[l][1]); //box check
    }
    ;
  }
  ;

  if (thisType.type == "MultiLineString") {
    for (var k = 0; k < thisType.coordinates.length; k++) {   //k enumerates linestrings, l enums points
      for (var l = 0; l < thisType.coordinates[k].length; l++) {
        xgtlt(bounds, thisType.coordinates[k][l][0]);
        ygtlt(bounds, thisType.coordinates[k][l][1]); //box check
      }
      ;
    }
    ;
  }
  ;

  if (thisType.type == "Polygon") {
    for (var k = 0; k < thisType.coordinates.length; k++) {
      // k enumerates polygons, l enumerates points
      for (var l = 0; l < thisType.coordinates[k].length; l++) {
        xgtlt(bounds, thisType.coordinates[k][l][0]);
        ygtlt(bounds, thisType.coordinates[k][l][1]); //box check
      }
      ;
    }
    ;
  }
  ;

  if (thisType.type == "MultiPolygon") {
    for (var j = 0; j < thisType.coordinates.length; j++) {		// j iterates over multipolygons   *-
      for (var k = 0; k < thisType.coordinates[j].length; k++) {  //k iterates over polygons
        for (var l = 0; l < thisType.coordinates[j][k].length; l++) {
          xgtlt(bounds, thisType.coordinates[j][k][l][0]);
          ygtlt(bounds, thisType.coordinates[j][k][l][1]); //box check
        }
        ;
      }
      ;
    }
    ;
  }
  ;
};        //getFeatureData


function xgtlt(bounds, xtest) {         // point-wise x-bound extender

  if (xtest < 0) {            // if western hemisphere,
    if (xtest > bounds.xmaxm) {    // xmaxm initially -180
      bounds.xmaxm = xtest;
    }
    if (xtest <= bounds.xminm) {   // xminm initially 0
      bounds.xminm = xtest;
    }
  }
  ;
  if (xtest >= 0) {                  // eastern hemisphere
    if (xtest >= bounds.xmaxp) {   // xmaxp initially 0
      bounds.xmaxp = xtest;
    }
    if (xtest <= bounds.xminp) {   // xminp initially 180
      bounds.xminp = xtest;
    }
  }
  ;
};

function ygtlt(bounds, ytest) {         // point-wise y-bound extender
  if (ytest > bounds.ymax) {
    bounds.ymax = ytest;
  }
  ;
  if (ytest < bounds.ymin) {
    bounds.ymin = ytest;
  }
  ;
};


