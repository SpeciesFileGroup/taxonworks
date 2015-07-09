/* Basic library to parse through TW returned geoJSON and draw a FeatureCollection on a Google Map.
 */

var initializeComplexMap;

initializeComplexMap = function (canvas, feature_collection) {
  var myOptions = {
    zoom: 1,
    center: {lat: 0, lng: 0}, //center_lat_long, set to 0,0
    mapTypeControl: true,
    mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
    navigationControl: true,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };

  var map = initialize_complex_map(canvas, myOptions);
  var data = feature_collection;
  var this_style = {};
  if (data != undefined) {
    var chained = JSON.parse('{"type":"FeatureCollection","features":[]}'); // container for the distribution
    if ((data["type"] == "Aggregation") && data.features[0].type == "FeatureCollection") {    //test for (currently) outer wrapper with property distribution
      if (data.features.length > 0) {
        var featureCollection = data.features;
        for (var i = 0; i < featureCollection.length; i++) {
          for (var j = 0; j < featureCollection[i].features.length; j++) {
            var push_this = false;
            var prefix;
            var this_feature = featureCollection[i].features[j];
            var this_property_key = Object.keys(featureCollection[i].properties);
            if (this_property_key == "asserted_distributions" && document.getElementById('check_dist').checked) {
              prefix = 'ad_';
              this_style.fillColor = '#880000';
              //this_style = '{ "icon": "/assets/mapicons/mm_20_gray.png", "fill": #440000, "stroke_opacity": 0.5, "stroke_width": 1, "fill_opacity": 0.2 }';
            push_this = true;
            }
            if (this_property_key == "collecting_events_georeferences" && document.getElementById('check_c_o').checked) {
              prefix = 'co_';
              this_style.fillColor = '#008800';
              //this_style = '{ "icon": "/assets/mapicons/mm_20_gray.png", "fill": #004400, "stroke_opacity": 0.5, "stroke_width": 1, "fill_opacity": 0.2 }';
              push_this = true;
            }
            if (this_property_key == "collecting_events_geographic_area" && document.getElementById('check_c_e').checked) {
              prefix = 'ce_';
              this_style.fillColor = '#000088';
              //this_style = '{ "icon": "/assets/mapicons/mm_20_gray.png", "fill": #000044, "stroke_opacity": 0.5, "stroke_width": 1, "fill_opacity": 0.2 }';
              push_this = true;
            }
            var index = this_feature.id.toString().indexOf(prefix);
            if(index >= 0) {
              this_feature_id = /*prefix +*/ this_feature.id.toString().slice(index + 3);   //isolate non-auto-generated part
            }
            else {
              this_feature_id = /*prefix +*/ this_feature.id.toString();
            }

            this_feature.id = prefix + this_feature_id;
            this_feature.properties[this_property_key] = this_property_key.toString();
            this_feature.properties["fillColor"] = this_style.fillColor;
            //map.data.addGeoJson(this_feature);

            //this_feature.style = this_style;
            if (push_this) {chained.features.push(this_feature)};
            //var this_style = '{fillColor: ' + fill_color.toString() + '}';
            //map.data.setStyle(this_style);
          }
        }
      }
    }   // if aggregation or
    else {
      chained = feature_collection;
    }
    map.data.addGeoJson(chained);
  }
  ;  // put data on the map if present
   
  //}  // put data on the map if present
  map.data.forEach(function(feature) {        // traverse map data for features

    this_feature = feature;
    this_property = this_feature.getProperty('source_type');
    if(this_property == 'asserted_distribution') {
      if (document.getElementById('check_dist').checked) {
        this_style.fillColor = '#880000';     //  red
      }
    }
    //this_property = this_feature.getProperty('collecting_events_georeferences');
    if(this_property == 'collecting_events_georeferences') {
      if (document.getElementById('check_c_o').checked) {
        this_style.fillColor = '#008800';     //  green
      }
    }
    //this_property = this_feature.getProperty('collecting_events_geographic_area');
    if(this_property == 'collecting_events_geographic_area') {
      if (document.getElementById('check_c_e').checked) {
        this_style.fillColor = '#000088';     //  blue
      }
    }
    //map.data.overrideStyle(this_feature, {fillColor: this_feature.getProperty("fillColor")});     //  whichever color
    map.data.overrideStyle(this_feature, {fillColor: this_style.fillColor});     //  whichever color
    map.data.overrideStyle(this_feature, {strokeWeight: 1});       // lightborders
    map.data.overrideStyle(this_feature, {fillOpacity: 0.3});       // semi-transparent
    map.data.overrideStyle(this_feature, {icon: '/assets/mapicons/mm_20_gray.png'});

///////////// SOMEHOW THESE LISTENERS BECAME BROKEN ON 08JUL15  ///////////////
    map.data.addListener('mouseover', function(event) {     // interim color shift on mousover paradigm changed to opacity
      map.data.overrideStyle(event.feature, {fillOpacity: 0.7});  // bolder
      if(event.feature.getProperty('geographic_area') != undefined) {
        $("#displayed_distribution_style").html(event.feature.getProperty('geographic_area').tag);
      }
      if(event.feature.getProperty('collecting_event') != undefined) {
        $("#displayed_distribution_style").html(event.feature.getProperty('collecting_event').tag);
      }
    });

    map.data.addListener('mouseout', function(event) {
      map.data.overrideStyle(event.feature, {fillOpacity: 0.3});  // dimmer
      $("#displayed_distribution_style").html('');
    });
  });
// bounds for calculating center point
  var bounds = {};    //xminp: xmaxp: xminm: xmaxm: ymin: ymax: -90.0, center_long: center_lat: gzoom:
  getComplexData(chained, bounds);               // scan var data as feature collection with homebrew traverser, collecting bounds
  var center_lat_long = get_window_center(bounds);      // compute center_lat_long from bounds and compute zoom level as gzoom
  // $("#map_coords").html('Center: \xA0 \xA0 \xA0 \xA0Latitude = ' + bounds.center_lat.toFixed(6) + ' , Longitude = ' + bounds.center_long.toFixed(6));
  map.setCenter(center_lat_long);
  map.setZoom(bounds.gzoom);

  return map;             // now no global map object, use this object to add listeners to THIS map
};

function initialize_complex_map(canvas, options) {
  var map = new google.maps.Map(document.getElementById(canvas), options);
  return map;
}


function getComplexData(feature_collection_data, bounds) {
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
        if (data[i].type == "FeatureCollection" || data[i].type == 'Aggregation') {
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

