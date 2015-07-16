/* Basic library to parse through TW returned geoJSON and draw a FeatureCollection on a Google Map.
 */

//var initializeComplexMap;
//
//initializeComplexMap = function (canvas, feature_collection) {
function initializeComplexMap(canvas, feature_collection) {
  var myOptions = {
    zoom: 1,
    center: {lat: 0, lng: 0}, //center_lat_long, set to 0,0
    mapTypeControl: true,
    mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
    navigationControl: true,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };

  //var map = initialize_complex_map(canvas, myOptions);
  var map = initialize_map(canvas, myOptions);
  map.data.setStyle(function (feature) {
    color = feature.getProperty('fillColor');   //
    return /** @type {google.maps.Data.StyleOptions} */({
      icon: '/assets/mapicons/mm_20_gray.png',
      fillColor: color,
      strokeColor: "black",
      strokeWeight: 1
    });
  });

  var data = feature_collection;
  if (data != undefined) {
    var chained = JSON.parse('{"type":"FeatureCollection","features":[]}'); // container for the distribution
    if (data["type"] == "FeatureCollection") {    //test for (revised) outer wrapper with depackaged property distribution
      if (data.features.length > 0) {
        var featureCollection = data;
        for (var i = 0; i < featureCollection.features.length; i++) {
          var this_feature = featureCollection.features[i];
          var this_property_key = this_feature.properties.source_type;
          var this_control = 'check_' + this_property_key;
          if (document.getElementById(this_control) != undefined) {   // if checkbox control exists
            if (document.getElementById(this_control).checked) {      // if checked
              chained.features.push(this_feature);
            }
          }
          else {
            chained.features.push(this_feature);    //functionality for non-checkbox-connected data
          }
         }
      }
    }   // if data.type == 'FeatureCollection'
    else {
      chained = data;   // and good luck with this ...
    }
    map.data.addGeoJson(chained);
  };  // put data on the map if present

// bounds for calculating center point
  var bounds = {};    //xminp: xmaxp: xminm: xmaxm: ymin: ymax: -90.0, center_long: center_lat: gzoom:
  getData(chained, bounds);               // scan var data as feature collection with homebrew traverser, collecting bounds
  var center_lat_long = get_window_center(bounds);      // compute center_lat_long from bounds and compute zoom level as gzoom
  map.setCenter(center_lat_long);
  map.setZoom(bounds.gzoom);
  return map;             // now no global map object, use this object to add listeners to THIS map
};

