/* Basic library to parse through TW returned geoJSON and draw a FeatureCollection on a Google Map.
 */

var initializeMap;

initializeMap = function (canvas, feature_collection) {
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

  map.data.setStyle(function (feature) {
    var color = feature.getProperty('fillColor');   //
    var icon = '/assets/mapicons/mm_20_gray.png';
    var color_name = feature.getProperty('colorName');
    if (color_name != undefined) {
      icon = '/assets/mapicons/mm_20_' + color_name + '.png'
    }
    var fill_opacity = feature.getProperty('fillOpacity');
    if (fill_opacity == undefined) {
      fill_opacity = 0.3;
    }
    return ({
      icon: icon,
      fillColor: color,
      fillOpacity: fill_opacity,
      strokeColor: "black",
      strokeOpacity: 0.5,
      strokeWeight: 1
    });   // @type {google.maps.Data.StyleOptions}
  });

  if (data != undefined) {
    var chained = JSON.parse('{"type":"FeatureCollection","features":[]}'); // container for the distribution
    if (data["type"] == "FeatureCollection") {  // once again, only looking for feature collections, but with properties
      doFeatureCollection(data, null, chained);
    }   // end: if data.type == 'FeatureCollection'
    else {              // this is not a feature collection, so what is it?
      if (data["otu_ids"] != undefined) {
        for (var j = 0; j < data["otu_ids"].length; j++) {
          this_otu_id = data["otu_ids"][j];
          this_feature_collection = data[this_otu_id];
          doFeatureCollection(this_feature_collection, this_otu_id, chained);
        }
      }
      else {
        chained = data;   // and good luck with this ...
      }
    }
    map.data.addGeoJson(chained);
  }
  ;  // put data on the map if present

// bounds for calculating center point
  var width;
  var height;
  var canvas_ratio = 1.0;     // default value
  var style = document.getElementById(canvas).style;

  if (style != null) {      // null short for undefined in js
    if (style.width != undefined && style.height != undefined) {
      width = style.width.toString().split('px')[0];
      height = style.height.toString().split('px')[0];
      canvas_ratio = width / height;
    }
  }
  var bounds = {};    //xminp: xmaxp: xminm: xmaxm: ymin: ymax: -90.0, center_long: center_lat: gzoom:
  getData(chained, bounds);               // scan var data as feature collection with homebrew traverser, collecting bounds
  bounds.canvas_ratio = canvas_ratio;
  bounds.canvas_width = width;
  bounds.canvas_height = height;
  var center_lat_long = get_window_center(bounds);      // compute center_lat_long from bounds and compute zoom level as gzoom
  map.setCenter(center_lat_long);
  map.setZoom(bounds.gzoom);
  //map.fitBounds(bounds.box);  /// no better results on non 2:1 canvas ratios
  if (document.getElementById("map_coords") != undefined) {
    document.getElementById("map_coords").textContent = 'LAT: ' + center_lat_long['lat']() + ' - LNG: '
      + center_lat_long['lng']() + ' - ZOOM: ' + bounds.gzoom;
  }
  var sw = bounds.sw;       // draw the bounding box for JDT
  var ne = bounds.ne;
  var coordList = [];
  coordList.push([sw['lng'](), sw['lat']()]);
  coordList.push([sw['lng'](), ne['lat']()]);
  if (sw['lng']() > 0 && ne['lng']() < 0) {
    coordList.push([180.0, ne['lat']()])
  }
  coordList.push([ne['lng'](), ne['lat']()]);
  coordList.push([ne['lng'](), sw['lat']()]);
  if (sw['lng']() > 0 && ne['lng']() < 0) {
    coordList.push([-180.0, sw['lat']()])
  }
  coordList.push([sw['lng'](), sw['lat']()]);
  var temparray = [];
  temparray[0] = coordList;
  coordList = temparray;        // this is an expedient kludge to get [[[lng,lat],...]]
  var bounds_box = {
    "type": "Feature",
    "geometry": {
      "type": "multilinestring",
      "coordinates": coordList
    },
    "properties": {}
  };
  map.data.addGeoJson(bounds_box);
  return map;             // now no global map object, use this object to add listeners to THIS map
};

function initialize_map(canvas, options) {
  var map = new google.maps.Map(document.getElementById(canvas), options);
  return map;
}

function doFeatureCollection(featureCollection, otu_id, chained) {
  if (featureCollection.features.length > 0) {
    for (var i = 0; i < featureCollection.features.length; i++) { // this loop looks for (currently) checkboxes that
      var this_feature = featureCollection.features[i];           // indicate inclusion into the google maps features
      var this_property_key = this_feature.properties.source_type;
      var this_control = 'check_' + this_property_key;    // + '_' + OTU_ID
      if (otu_id != null) {
        this_control += '_' + otu_id
      }
      if (document.getElementById(this_control) != undefined) {   // if checkbox control exists
        if (document.getElementById(this_control).checked) {      // if checked, and only
          this_feature.properties.otu_id = otu_id;
          chained.features.push(this_feature);                    // if checked, insert this feature/properties
        }                                                         // otherwise skip this feature
      }
      else {                                    // if no corresponding control property, do not block insertion
        chained.features.push(this_feature);    // functionality for non-checkbox-connected data
      }
    }
  }
}

function log_2(x) {
  return Math.log(x) / Math.LN2;  // log_2(x) = ln(x)/ln(2)
}

function get_window_center(bounds) {      // for use with home-brew geoJSON scanner/enumerator
  var xminp = bounds.xminp;           //
  var xmaxp = bounds.xmaxp;           //
  var xminm = bounds.xminm;           //
  var xmaxm = bounds.xmaxm;           // these elements already set
                                      //
  var ymin = bounds.ymin;             //
  var ymax = bounds.ymax;             //

  var center_long = bounds.center_long;   // these elements are calculated here,
  var center_lat = bounds.center_lat;     // unless preset validly in data-map-center
  var gzoom = bounds.gzoom;               //

  if (center_long == undefined) {    //determine case of area extent
    center_long = 0.0;
    var wm = 0.0;        // western hemisphere default area width
    var wp = 0.0;        // eastern hemisphere default area width
    if ((xminp == 180.0) && (xmaxp == 0.0)) {    //if no points, null out the range for this hemisphere
      xminp = 0.0;
    }
    if ((xmaxm == -180.0) && (xminm == 0.0)) {    //if no points, null out the range for this hemisphere
      xmaxm = 0.0;
    }
    if ((xminp == 0.0) && (xmaxp == 0.0) && (xmaxm == 0.0) && (xminm == 0.0)) {   // no data (kinda)
      xminm = -180.0;     // this calculation is to reflect
      xmaxp = 180.0;      // latitude calculation below
      center_long = 0.0;
      wx = 360.;
    }
    else {
      // case of singleton poiint in either hemisphere not well treated below (still true? - JRF 20JUL2015)
      wm = xmaxm - xminm;    // width of western area, if present
      wp = xmaxp - xminp;    // width of eastern area, if present
      var xmm = xminm + 0.5 * wm;     // midpoint of west
      var xmp = xminp + 0.5 * wp;     // midpoint of east
      var wxp;                    // width to anti/prime meridian east
      var wxm;                    // width to anti/prime meridian west
      var wx;                               // total width of all areas
      wx = xmaxp - xminm;             // assume data in both hemispheres default across prime meridian
      if (wx > 180) {               // areas are > 180 degrees wide or cross prime meridian
        if (wm == 0 && wp == 0) {   // this is the case of single longitude in each (both!) hemisphere
          wx = 360 - wx;                              // so revert to < 180 degree width (smaller distance)
          center_long = (xminm + xmaxp) / 2 - 180;   // left-hand expression is near antimerdian
        }
        else {
          if (wm == 0 || wp == 0) {                // only one point in either hemisphere and multiples/areas in the opposite
            if (wm == 0) {     // if single point in western hemisphere
              wxp = 180 - xminp;    // xmaxp = xminp for single point
              wxm = 180 + xmaxm;    // western half
              wx = wxp + wxm;
              if (wxm > wxp) {      // is western hemisphere part bigger?
                center_long = xmaxm - wx / 2 - 180;
                wx = wx - 0;     ////  DUMMY
              }
              else {      // eastern width is greater
                center_long = xminp + wx / 2;
                wx = wx - 0;     ////  DUMMY
              }
            }
            else {        // wp = 0
              wxp = 180 - xminp;    // xmaxp = xminp for single point
              wxm = 180 + xmaxm;    // western half
              wx = wxp + wxm;
              if (wxm > wxp) {
                center_long = -0.5 * (wxp + wxm);
                center_long = (xminp + xmaxm) / 2 - 180;
                wx = wx - 0;     ////  DUMMY
              }
              else {
                center_long = 0.5 * (wxp + wxm);
                wx = wx - 0;     ////  DUMMY
              }
            }
          }
          else {        // area in both hemispheres, but spans over 180 degrees or crosses antimeridian
            wxp = 180 - xminp;    // xmaxp = xminp for single point
            wxm = 180 + xmaxm;    // western half
            wx = wxp + wxm;
            if (wxm > wxp) {
              center_long = (xminp + xmaxm) / 2 - 180;
              wx = wx - 0;     ////  DUMMY
            }
            else {
              center_long = xminp + wx / 2;
              wx = wx - 0;     ////  DUMMY
            }
            wx = wx - 0;     ////  DUMMY
          }
        }

      }
      else {            // not an overwide calculation
        if (wp == 0) {
          wx = wm;
        }         // override for single sided western hemisphere
        if (wm == 0) {
          wx = wp;
        }         // override for single sided eastern hemisphere
        if (xmaxp > 179 && xminm < -179) {      // Antimeridian span test
          wx = wm + wp;                        // total width of eastern and western
          if (wm > wp) {                       // determine wider group
            center_long = xmm - wp / 2;        // adjust western mid/mean point by half width of eastern
            if (center_long < -180) {
              center_long = 360 - center_long;
            }       // bias from -180
          }                                    // e.g., USA
          else {
            center_long = xmp + wm / 2;        // adjust positive mean/mid point by half width of western
            if (center_long > 180) {
              center_long = center_long - 360;
            }        // bias from +180
          }
          // assume: calculate center about +/- 180 over contiguous spanning area
          //center_long = (xminp + xmaxm) / 2.0;    // revised simplified calculation JRF 04AUG2015
        }
        else {                                 // i.e., if not Antimeridian span, center on extents about 0
          // case disjoint areas divided by prime meridian or single point
          if (wx != 0) {
            center_long = (xminm + xmaxp) / 2;        // default calculation for both hemisperes having data
            if (wp == 0) {
              center_long = xmm;
            }         // override for single sided western hemisphere
            if (wm == 0) {
              center_long = xmp;
            }         // override for single sided eastern hemisphere
          }
          else {        // single point
            if (xmm == 0) {
              center_long = xmp;
            }
            if (xmp == 0) {
              center_long = xmm;
            }
          }
        }
      }// e.g., USA
    }
  }   // END center_long == undefined
  var offset = 0;                 // scope extended to be used in zoom calculation later
  if (center_lat == undefined) {
    if ((ymax == -90) && (ymin == 90)) {      // no data, so set whole earth limits
      ymax = 90.0;
      ymin = -90.0;
      center_lat = 0.0;
    }
    var wy = ymax - ymin;
    center_lat = 0.5 * (ymax + ymin);
    if (Math.abs(center_lat) > 1.0) {           // if vertical center not very close to equator
      var cutoff = 65.0;                        // empirically determined latitude
      if ((ymax > cutoff || ymin < -cutoff)) {  // if any vertical extent beyond cutoff
        var angle = ymax - cutoff;              // calculate
        if (center_lat < 0) {                   // angular distance
          angle = ymin + cutoff;                //  beyond cutoff
        }
        offset = Math.cos((angle /*- center_lat*/) / (180.0 / 3.1415926535));
        offset = 0.1 * (ymax - ymin) / offset;    // signed result in degrees(?)
        center_lat = center_lat + offset;
      }
    }
  }

  var sw = new google.maps.LatLng(ymin, center_long - 0.5 * wx);     // correct x JRF 29JUL2015
  bounds.sw = sw;
  var ne = new google.maps.LatLng(ymax, center_long + 0.5 * wx);     // correct x
  bounds.ne = ne;
  var box = new google.maps.LatLngBounds(sw, ne);

  var xzoom;
  var yzoom;

  ///// Google Maps only shows whole earth at zoom 1 if square canvas
  ///// Google Maps cuts off latitude at ~85+/- degrees
  ///// Hence vertical degrees yield twice as many pixels per degree as horizontal ones
  ///// for a square canvas
  ///// NOTE:  Google maps alias longitudes at zoom 1 unless canvas width is 2^n
  ///// calibrate zoom to canvas by ~  Math.pow(2, Math.floor(log_2(bounds.canvas_width)))
  ///// @ zoom = 0, the world is 256 x 256 pixels

  var x_deg_per_pix = 360.0 / bounds.canvas_width;
  var y_deg_per_pix = 170.0 / bounds.canvas_height / bounds.canvas_ratio;    // ?;
  y_deg_per_pix = (170.0 / bounds.canvas_ratio) / bounds.canvas_height;    // ?;
  y_deg_per_pix = 170.0 / (bounds.canvas_ratio * bounds.canvas_height);    // ?;

  var x_pixels_per_degree = bounds.canvas_width / 360;
  var y_pixels_per_degree = bounds.canvas_height / 170 * bounds.canvas_ratio; // mercator cutoff latitude
  y_pixels_per_degree = bounds.canvas_height / (170 / bounds.canvas_ratio); // mercator cutoff latitude
  // need mercator adjustment: approximate by

  var x_pixels = wx / x_deg_per_pix;
  var y_pixels = wy / y_deg_per_pix;

  x_pixels = wx * x_pixels_per_degree;
  //y_pixels = wy * y_pixels_per_degree;
  y_pixels = wy * y_pixels_per_degree / (Math.cos((center_lat) / (180.0 / 3.1415926535)));

  var aspect_ratio = x_pixels / y_pixels;   //changed from wx/wy//
  if (x_pixels / bounds.canvas_width > y_pixels / bounds.canvas_height) {     // wider
    // pick x-axis
    xzoom = 1.0 - log_2(x_pixels / bounds.canvas_width);      // empirical inversion of log result
    if (xzoom > 15 || xzoom == Infinity) {
      xzoom = 15;
    }
    gzoom = Math.floor(xzoom);
    if ((x_pixels * Math.pow(2, gzoom) * 2 < bounds.canvas_width) && (y_pixels * Math.pow(2, gzoom) * 2 < bounds.canvas_height)) {   // if I zoom again will it be not too wide?
      gzoom = gzoom + 1;
    }
  }
  else {                                        // wider
    // pick y-axis
    yzoom = 1.2 - log_2((y_pixels / bounds.canvas_height) /*/ bounds.canvas_ratio*/);      // terms expanded for debugging purposes
    if (yzoom > 15 || yzoom == Infinity) {
      yzoom = 15;
    }
    gzoom = Math.floor(yzoom);
    if ((x_pixels * Math.pow(2, gzoom) < bounds.canvas_width) && (y_pixels * Math.pow(2, gzoom - 1) < bounds.canvas_height)) {   // if I zoom again will it be not too wide?
      gzoom = gzoom + 1;
    }
  }
/////// patch in new zoom calculation
//  xzoom = Math.floor(log_2((bounds.canvas_width / 256) * (360 / wx) ) );
//  yzoom = Math.floor(log_2((bounds.canvas_height / 256) * (360 / wy) ) );
//  xzoom = -Math.floor(log_2(1 / ( (bounds.canvas_width / 256) * (360 / wx) ) ) );
//  yzoom = -Math.floor(log_2( 1 / ((bounds.canvas_height / 256) * (360 / wy) ) ) );
//  gzoom = Math.min(xzoom, yzoom, 15);
///////
  if (wx > 90.0 || wy * bounds.canvas_ratio > 45.0) {   // Band-aids to cover USA, etc.
    gzoom = 2
  }
  if (wx > 180.0) {
    gzoom = 1
  }

  bounds.center_lat = center_lat;
  bounds.center_long = center_long;
  bounds.gzoom = gzoom;
  bounds.box = box;
  return new google.maps.LatLng(center_lat, center_long);
}

// bounds for calculating center point
// divide longitude checks by hemisphere
// variables below used by stripped-down getData to compute bounds
// used to clear previous history
// so that center is recalculated
function reset_center_and_bounds(bounds) {
  bounds.center_long = undefined;     // current data-elements always (wrongly) contain -map-center='POINT (0.0 0.0 0.0)'
  bounds.center_lat = undefined;      // this section should set these bounds from data element when properly present

  bounds.xminp = 180.0;       // use 0
  bounds.xmaxp = 0.0;        // to
  bounds.xminm = 0.0;       // +/-180-based
  bounds.xmaxm = -180.0;   // coordinates for longitude

  bounds.ymin = 90.0;    // +/-90 for latitude
  bounds.ymax = -90.0;

  bounds.gzoom = 1;   // default zoom to whole earth
  bounds.box = new google.maps.LatLngBounds(new google.maps.LatLng(bounds.ymax, bounds.xmaxm),
    new google.maps.LatLng(bounds.ymin, bounds.xminp));
  bounds.canvas_ratio = 1;    // overridable prior to get_window_center
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
        }
        else {
          getTypeData(data[i], bounds);
        }  //data[i].type
      }     //data[i] != undefined
    }        // for i
  }           //data != undefined
}             //getData

function getFeature(thisFeature, bounds) {
  if (thisFeature.type == "FeatureCollection") {
    getTypeData(thisFeature, bounds);   // if it requires recursion on FC
  }
  else {
    getTypeData(thisFeature.geometry, bounds);
  }
}

function getTypeData(thisType, bounds) {        // this version does not create google objects

  if (thisType == undefined) {      // this test if to avoid js errors from  features without geometry
    return                          // google maps forgives features wthout geometries
  }
  if (thisType.type == "FeatureCollection") {
    for (var i = 0; i < thisType.features.length; i++) {
      if (typeof (thisType.features[i].type) != "undefined") {
        getFeature(thisType.features[i], bounds);		//  recurse if FeatureCollection
      }     //thisType != undefined
    }        //for i
    return
  }

  if (thisType.type == "GeometryCollection") {
    for (var i = 0; i < thisType.geometries.length; i++) {
      if (typeof (thisType.geometries[i].type) != "undefined") {
        getTypeData(thisType.geometries[i], bounds);		//  recurse if GeometryCollection
      }     //thisType != undefined
    }       //for i
  }

  if (thisType.type == "Point") {
    xgtlt(bounds, thisType.coordinates[0]);
    ygtlt(bounds, thisType.coordinates[1]); //box check
  }

  if (thisType.type == "MultiPoint") {
    for (var l = 0; l < thisType.coordinates.length; l++) {
      xgtlt(bounds, thisType.coordinates[l][0]);
      ygtlt(bounds, thisType.coordinates[l][1]); //box check
    }
  }

  if (thisType.type == "LineString") {
    for (var l = 0; l < thisType.coordinates.length; l++) {
      xgtlt(bounds, thisType.coordinates[l][0]);
      ygtlt(bounds, thisType.coordinates[l][1]); //box check
    }
  }

  if (thisType.type == "MultiLineString") {
    for (var k = 0; k < thisType.coordinates.length; k++) {   //k enumerates linestrings, l enums points
      for (var l = 0; l < thisType.coordinates[k].length; l++) {
        xgtlt(bounds, thisType.coordinates[k][l][0]);
        ygtlt(bounds, thisType.coordinates[k][l][1]); //box check
      }
    }
  }

  if (thisType.type == "Polygon") {
    for (var k = 0; k < thisType.coordinates.length; k++) {
      // k enumerates polygons, l enumerates points
      for (var l = 0; l < thisType.coordinates[k].length; l++) {
        xgtlt(bounds, thisType.coordinates[k][l][0]);
        ygtlt(bounds, thisType.coordinates[k][l][1]); //box check
      }
    }
  }

  if (thisType.type == "MultiPolygon") {
    for (var j = 0; j < thisType.coordinates.length; j++) {		// j iterates over multipolygons   *-
      for (var k = 0; k < thisType.coordinates[j].length; k++) {  //k iterates over polygons
        for (var l = 0; l < thisType.coordinates[j][k].length; l++) {
          xgtlt(bounds, thisType.coordinates[j][k][l][0]);
          ygtlt(bounds, thisType.coordinates[j][k][l][1]); //box check
        }
      }
    }
  }
}        //getFeatureData


function xgtlt(bounds, xtest) {         // point-wise x-bound extender

  if (xtest < 0) {            // if western hemisphere,
    if (xtest > bounds.xmaxm) {    // xmaxm initially -180
      bounds.xmaxm = xtest;
    }
    if (xtest <= bounds.xminm) {   // xminm initially 0
      bounds.xminm = xtest;
    }
  }
  if (xtest >= 0) {                  // eastern hemisphere
    if (xtest >= bounds.xmaxp) {   // xmaxp initially 0
      bounds.xmaxp = xtest;
    }
    if (xtest <= bounds.xminp) {   // xminp initially 180
      bounds.xminp = xtest;
    }
  }
}

function ygtlt(bounds, ytest) {         // point-wise y-bound extender
  if (ytest > bounds.ymax) {
    bounds.ymax = ytest;
  }
  if (ytest < bounds.ymin) {
    bounds.ymin = ytest;
  }
}


