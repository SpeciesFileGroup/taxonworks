/* Basic library to parse through TW returned geoJSON and draw a polygon on a Google Map.  
 * Lots of optimization etc. possible down the road.
 *
 */

var map;	// google map object
var data; // TaxonWorks jSON data

var gPoints = [];		//googlemaps arrays
var gLinePoints = [];
var gPolyPoints = [];

// var lPoints = [];

// bounds for calculating center point
// divide longitude checks by hemisphere
var xminp = 180.0;       //return to 0-based coordinates
var xmaxp = 0.0;
var xminm = 0.0;         //return to 0-based coordinates
var xmaxm = -180.0;

var ymin = 90.0;
var ymax = -90.0;

// used to center the map in the window
var center_long;
var center_lat;
var center_lat_long;

// zoom level
var gzoom = 1;      // default to fairly far out

var initialize;

initialize = function () {
    // bounds = new google.maps.LatLngBounds();
    //get_data();
    //get_window_center();

    var myOptions = {
        zoom: gzoom,
        center: {lat:0, lng: 0}, //center_lat_long, set to 0,0
        mapTypeControl: true,
        mapTypeControlOptions: { style: google.maps.MapTypeControlStyle.DROPDOWN_MENU },
        navigationControl: true,
        mapTypeId: google.maps.MapTypeId.TERRAIN
    };

    initialize_map(myOptions);
    //add_shapes_to_map();      // old home-brew interpreter and range/bounds/center function
    //if (data["type"] != "Feature" && data["type"] != "FeatureCollection") {     // forgive older style JSON without Feature, etc.
    //    datastring = JSON.stringify(data);
    //    datastring = '{ "type": "Feature", "geometry": ' + datastring + '}';
    //    datafeature = JSON.parse(datastring);
    //    data = datafeature;
    //}
    map.data.setStyle({fillColor: '#440000', strokeOpacity: 0.5, strokeColor: "black", strokeWeight: 1, fillOpacity: 0.3})
    map.data.addGeoJson(data);

    //centerofmap = map.getCenter();      // not getting desired result

   //zoomAndCenter(map)

    get_Data();
    get_window_center();
    //document.getElementById('map_coords').html = 'Center: \xA0 \xA0 \xA0 \xA0Latitude = ' + center_lat.toFixed(6) + ' , Longitude = ' + center_long.toFixed(6);
// converted to jQuery syntax
    $("#map_coords").html('Center: \xA0 \xA0 \xA0 \xA0Latitude = ' + center_lat.toFixed(6) + ' , Longitude = ' + center_long.toFixed(6)) ;
    map.setCenter(center_lat_long);
    map.setZoom(gzoom);

    map.data.setStyle(function(feature) {
        var color = '#440000';  // dimmer red
        if (feature.getProperty('isColorful')) {
            color = feature.getProperty('fillColor');
        }
        return /** @type {google.maps.Data.StyleOptions} */({
            fillColor: color,
            strokeColor: "black",
            strokeWeight: 1
        });
    });
    // When the user clicks, set 'isColorful', changing the color of the feature.
    map.data.addListener('click', function(event) {
        event.feature.setProperty('isColorful', true);
        event.feature.setProperty('fillColor', "#CC0000");  //brighter red
        var mapLatLng = event.latLng;
        $("#map_coords").html('Coordinates: Latitude = ' + mapLatLng.lat().toFixed(6) + ', Longitude = ' + mapLatLng.lng().toFixed(6))
        + '&asserted_distribution[source_id]=' + source_id + '&asserted_distribution[otu_id]=' + otu_id,
        $.get('generate_choices?latitude=' + mapLatLng.lat().toFixed(9) + '&longitude=' + mapLatLng.lng().toFixed(9),
            function(coors, status){
                //map.setCenter(new google.maps.LatLng(coors["lat"],coors["lon"]));
                map.setCenter(mapLatLng);       // since coors is no longer being sent back as coords
                //$("#map_coords").html(coors);
                $("#map_coords").append(coors);
            });
    });

    // When the user hovers, tempt them to click by outlining the letters.
    // Call revertStyle() to remove all overrides. This will use the style rules
    // defined in the function passed to setStyle()
    map.data.addListener('mouseover', function(event) {
        map.data.revertStyle();
        map.data.overrideStyle(event.feature, {fillColor: '#880000'});  // mid-level red
        map.data.overrideStyle(event.feature, {strokeWeight: 4});       //embolden borders
    });

    map.data.addListener('mouseout', function(event) {
        map.data.revertStyle();
    });

    google.maps.event.addListener(map, 'click', function (event) {
        var mapLatLng = event.latLng;
        //lat = mapLatLng.lat();
        //lng = mapLatLng.lng();
        //document.getElementById('map_coords').text = 'Coordinates: Latitude = ' + lat.toFixed(6) + ' , Longitude = ' + lng.toFixed(6);
        $("#map_coords").html('Coordinates: Latitude = ' + mapLatLng.lat().toFixed(6) + ' , Longitude = ' + mapLatLng.lng().toFixed(6)) ;
     
     
        //$("#map_canvas").after('<br />Coordinates: Latitude = ' + mapLatLng.lat().toFixed(6) + ', Longitude = ' + mapLatLng.lng().toFixed(6) + '<br />') ;
        $("#latitude").val(mapLatLng.lat());
        $("#longitude").val(mapLatLng.lng());
        
          $.get( 'generate_choices', $('form#cadu').serialize(), function(local_data) {
            $("#qnadf").html(local_data['html']);
            //coors_element = JSON.parse(document.getElementById('json_coors').value);
            //map.setCenter(new google.maps.LatLng(coors_element["lat"],coors_element["lon"]));

            map.data.addGeoJson(local_data['feature_collection']);
         
            data = local_data['feature_collection']; 
         // get_Data();
         // get_window_center();
         // map.setCenter(center_lat_long);
         // map.setZoom(gzoom);
          },
          'json' // I expect a JSON response
          );


      //$.get('generate_choices?latitude=' + mapLatLng.lat().toFixed(9) + '&longitude=' + mapLatLng.lng().toFixed(9)
      //    + '&asserted_distribution[source_id]=' + source_id + '&asserted_distribution[otu_id]=' + otu_id,
     
      //    function(coors, status){
      //    //map.setCenter(new google.maps.LatLng(coors["lat"],coors["lon"]));
      //    //map.setCenter(mapLatLng);       // since coors is no longer being sent back as coords
      //    //$("#map_coords").html(coors);
       //        });

        //$.post("display_coordinates",
        //    {lat: mapLatLng.lat().toFixed(9),
        //     lon: mapLatLng.lng().toFixed(9)},
        //function(coors, status){
        //    map.setCenter(new google.maps.LatLng(coors["lat"],coors["lon"]));
            //$("#map_coords").html(coors);
        //});
    });
};

function initialize_map(options) {
    map = new google.maps.Map(document.getElementById("map_canvas"), options);
}

function zoomAndCenter(map) {       // for use with Google bounds method
    var bounds = new google.maps.LatLngBounds();
    map.data.forEach(function(feature) {
        processPoints(feature.getGeometry(), bounds.extend, bounds)
    });
    map.fitBounds(bounds);
}

/**
 * Process each point in a Geometry, regardless of how deep the points may lie.
 * @param {google.maps.Data.Geometry} geometry The structure to process
 * @param {function(google.maps.LatLng)} callback A function to call on each
 *     LatLng point encountered (e.g. Array.push)
 * @param {Object} thisArg The value of 'this' as provided to 'callback' (e.g.
 *     myArray)
 */

function processPoints(geometry, callback, thisArg) {
    if(geometry instanceof google.maps.LatLng) {
        callback.call(thisArg, geometry)
} else if (geometry instanceof google.maps.Data.Point) {
    callback.call(thisArg, geometry.get());
    } else {
        geometry.getArray().forEach(function(g) {
            processPoints(g, callback, thisArg);
        });
    }
}
        // this function fails on single point, esp in western hemisphere
function get_window_center() {      // for use with home-brew geoJSON scanner/enumerator
    if (center_long == undefined) {
        //determine case of area extent
        center_long = 0.0;
        wm = 0.0;        // western hemisphere default area width
        wp = 0.0;        // eastern hemisphere default area width
        if ((xminp == 180.0) && (xmaxp == 0.0)) {    //if no points, null out the range for this hemisphere
            xminp = 0.0;
        }
        if ((xmaxm == -180.0) && (xminm == 0.0)) {    //if no points, null out the range for this hemisphere
            xmaxm = 0.0;
        }
        wm = xmaxm - xminm;    // width of western area, if present
        wp = xmaxp - xminp;    // width of eastern area, if present
        xmm = xminm + 0.5 * wm;     // midpoint of west
        xmp = xminp + 0.5 * wp;     // midpoint of east
        wx = wm + wp;                               // total width of "contiguous" area
        center_long = xmm + xmp;    //as signed, unless overlaps +/-180
        if(wm > wp){                // serious cheat: pick mean longitude of wider group
            center_long = xmm       // "works" since there are so few cases that span
        }                           // the Antimeridian
        if(wm < wp){
            center_long = xmp
        }
    }
    ;
    if (center_lat == undefined) {
        if((ymax == -90) && (ymin == 90)) {ymax = 90.0; ymin = -90.0;}      // no data, so set whole earth limits
        wy = ymax - ymin;
        center_lat = 0.5 * (ymax + ymin);
        cutoff = 65.0
        if(/*Math.abs(center_lat) > 45.0 &&*/ (ymax > cutoff || ymin < -cutoff)) {
            angle = ymax - cutoff;
            if (center_lat < 0) {
                angle = ymin + cutoff;
            }
            offset = Math.cos((angle /*- center_lat*/)/ (180.0/3.1415926535));
            offset = 0.1 * (ymax-ymin)/offset;
            center_lat = center_lat + offset;
        }
    }
    ;

    if(wy > 0.5 * wx) {wx = wy * 2.5}
    if (wx <= 0.1) {gzoom =11};
    if (wx > 0.1) {gzoom = 10};
    if (wx > 0.2) {gzoom = 9};
    if (wx > 0.5) {gzoom = 8};
    if (wx > 1.0) {gzoom = 7};
    if (wx > 2.5) {gzoom = 6};
    if (wx > 5.0) {gzoom = 5};
    if (wx > 10.0) {gzoom = 4};
    if (wx > 40.0) {gzoom = 3};
    if (wx > 80.0) {gzoom = 2};
    if (wx > 160.0 || (wx + wy) == 0) {gzoom = 1};
    //alert('wx = ' + wx + '\ngzoom = ' + gzoom + '\nxminm = ' + xminm + '\nxmaxm = ' + xmaxm + '\nxminp = ' + xminp + '\nxmaxp = ' + xmaxp + '\nlong = ' + center_long + '\nlat = ' + center_lat);
    center_lat_long = new google.maps.LatLng(center_lat, center_long);
};

function add_shapes_to_map() {
    if (typeof (gPoints) != 'undefined') {
        var gPoint;
        for (var k = 0; k < gPoints.length; k++) {
            gPoint = createPoint(gPoints[k], "#880000");
            gPoint.setMap(map);
        }
        ;
    }
    ;

    if (typeof (gLinePoints) != 'undefined') {
        for (var k = 0; k < gLinePoints.length; k++) {
            //	var gLine = createLine(gLinePoints[k], "black");	//did not work!!!??!!!???
            var gLine = new google.maps.Polyline({
                path: gLinePoints[k],
                geodesic: false,
                strokeColor: '#FF0000',
                strokeOpacity: 0.5,
                strokeWeight: 1
            });
            gLine.setMap(map);
        }
        ;
    }
    ;

    if (typeof (gPolyPoints) != 'undefined') {
        var gPoly;
        for (var k = 0; k < gPolyPoints.length; k++) {
            gPoly = createPolygon(gPolyPoints[k], "#880000");
            gPoly.setMap(map);
        }
        ;
    }
    ;
    //    map.fitBounds(bounds);
};

function get_Data() {       //this is the scanner version; no google objects are created
    /*		get data object encoded as geoJSON and disseminate to google and leaflet arrays
     Assumptions:
     data is a hash
     Multi- geometry types are composed of simple (homogeneous) types: Point, LineString, Polygon
     these are collected as xPoints[], xLinePoints[], xPolyPoints[]; x = g | l for google and leafletjs respectively
     this leaves ambiguous the association of attributes to the objects (e.g., color, etc.)
     New realization: there may or may not be GeometryCollections, which may contain any type, including GeometryCollection !  $#!+
     */
    if (typeof (data) != 'undefined') {
        var dataArray = [];
        if (data instanceof Array) {
        }      // if already an array, then do nothing
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
                        getFeature(data[i].features[j]);  //getTypeData(data[i].features[j].geometry);
                    }
                }
            if (data[i].type == "GeometryCollection") {
                for (var j = 0; j < data[i].geometries.length; j++) {
                    getTypeData(data[i].geometries[j]);
                }
                ;
            }
            else {
                getTypeData(data[i]);
            }    //data.type
        }
        ;     //data[i] != undefined
     }        // for i
    }
    ;         //data != undefined
 }
 ;

function getFeature(thisFeature) {
    getTypeData(thisFeature.geometry);
}

function getTypeData(thisType) {        // this version does not create google objects

    if (thisType.type == "FeatureCollection") {
        for (var i = 0; i < thisType.features.length; i++) {
            if (typeof (thisType.features[i].type) != "undefined") {
                getFeature(thisType.features[i]);		//  recurse if FeatureCollection
            }
            ;     //thisType != undefined
        }
        ;       //for i
    }
    ;

    if (thisType.type == "GeometryCollection") {
        for (var i = 0; i < thisType.geometries.length; i++) {
            if (typeof (thisType.geometries[i].type) != "undefined") {
                getTypeData(thisType.geometries[i]);		//  recurse if GeometryCollection
            }
            ;     //thisType != undefined
        }
        ;       //for i
    }
    ;

    if (thisType.type == "Point") {
        xgtlt(thisType.coordinates[0]);
        ygtlt(thisType.coordinates[1]); //box check
    }
    ;

    if (thisType.type == "MultiPoint") {
        for (var l = 0; l < thisType.coordinates.length; l++) {
            xgtlt(thisType.coordinates[l][0]);
            ygtlt(thisType.coordinates[l][1]); //box check
        }
        ;
    }
    ;

    if (thisType.type == "LineString") {
        for (var l = 0; l < thisType.coordinates.length; l++) {
            xgtlt(thisType.coordinates[l][0]);
            ygtlt(thisType.coordinates[l][1]); //box check
        }
        ;
    }
    ;

    if (thisType.type == "MultiLineString") {
        for (var k = 0; k < thisType.coordinates.length; k++) {   //k enumerates linestrings, l enums points
            //var m = gLinePoints.length;
            //gLinePoints[m] = [];
            for (var l = 0; l < thisType.coordinates[k].length; l++) {
                xgtlt(thisType.coordinates[k][l][0]);
                ygtlt(thisType.coordinates[k][l][1]); //box check
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
                xgtlt(thisType.coordinates[k][l][0]);
                ygtlt(thisType.coordinates[k][l][1]); //box check
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
                    xgtlt(thisType.coordinates[j][k][l][0]);
                    ygtlt(thisType.coordinates[j][k][l][1]); //box check
                }
                ;
            }
            ;
        }
        ;
    }
    ;
};        //getFeatureData

//function get_data() {         // this version creates the google objects, without preserving features
//    /*		get data object encoded as geoJSON and disseminate to google and leaflet arrays
//     Assumptions:
//     data is a hash
//     Multi- geometry types are composed of simple (homogeneous) types: Point, LineString, Polygon
//     these are collected as xPoints[], xLinePoints[], xPolyPoints[]; x = g | l for google and leafletjs respectively
//     this leaves ambiguous the association of attributes to the objects (e.g., color, etc.)
//     New realization: there may or may not be GeometryCollections, which may contain any type, including GeometryCollection !  $#!+
//     */
//    if (typeof (data) != 'undefined') {
//        var dataArray = [];
//        if (data instanceof Array) {
//        }      // if already an array, then do nothing
//        else    // convert it to an array
//        {
//            dataArray[0] = data;
//            data = [];
//            data[0] = dataArray[0];
//        }
//        ;
//        for (var i = 0; i < data.length; i++) {
//            if (typeof (data[i].type) != "undefined") {
//                if (data[i].type == "GeometryCollection") {
//                    for (var j = 0; j < data[i].geometries.length; j++) {
//                        getTypeData(data[i].geometries[j]);
//                    }
//                    ;
//                }
//                else {
//                    getTypeData(data[i]);
//                }    //data.type
//            }
//            ;     //data[i] != undefined
//        }        // for i
//    }
//    ;         //data != undefined
//};
//
//// detect and extract geometry types from higher level enumerator, recursible
//function getTypeData(thisType) {
//
//    if (thisType.type == "GeometryCollection") {
//        for (var i = 0; i < thisType.geometries.length; i++) {
//            if (typeof (thisType.geometries[i].type) != "undefined") {
//                getTypeData(thisType.geometries[i]);		//  recurse if GeometryCollection
//            }
//            ;     //thisType != undefined
//        }
//        ;       //for i
//    }
//    ;
//
//    if (thisType.type == "Point") {
//        xgtlt(thisType.coordinates[0]);
//        ygtlt(thisType.coordinates[1]); //box check
//        gPoints.push(new google.maps.LatLng(thisType.coordinates[1], thisType.coordinates[0]));
//    }
//    ;
//
//    if (thisType.type == "MultiPoint") {
//        for (var l = 0; l < thisType.coordinates.length; l++) {
//            //xgtlt(thisType.coordinates[j][k][l][0]);
//            //ygtlt(thisType.coordinates[j][k][l][1]); //box check
//            gPoints.push(new google.maps.LatLng(thisType.coordinates[l][1], thisType.coordinates[l][0]));
//        }
//        ;
//    }
//    ;
//
//    if (thisType.type == "LineString") {
//        var m = gLinePoints.length;
//        gLinePoints[m] = [];
//        for (var l = 0; l < thisType.coordinates.length; l++) {
//            //xgtlt(thisType.coordinates[j][k][l][0]);
//            //ygtlt(thisType.coordinates[j][k][l][1]); //box check
//            gLinePoints[m].push(new google.maps.LatLng(thisType.coordinates[l][1], thisType.coordinates[l][0]));
//        }
//        ;
//    }
//    ;
//
//    if (thisType.type == "MultiLineString") {
//        for (var k = 0; k < thisType.coordinates.length; k++) {   //k enumerates linestrings, l enums points
//            var m = gLinePoints.length;
//            gLinePoints[m] = [];
//            for (var l = 0; l < thisType.coordinates[k].length; l++) {
//                //xgtlt(thisType.coordinates[j][k][l][0]);
//                //ygtlt(thisType.coordinates[j][k][l][1]); //box check
//                gLinePoints[m].push(new google.maps.LatLng(thisType.coordinates[k][l][1], thisType.coordinates[k][l][0]));
//            }
//            ;
//        }
//        ;
//    }
//    ;
//
//    if (thisType.type == "Polygon") {
//        for (var k = 0; k < thisType.coordinates.length; k++) {
//            // k enumerates polygons, l enumerates points
//            var m = gPolyPoints.length;
//            gPolyPoints[m] = [];		//create a new coordinate/point array for this (m/n) polygon
//            for (var l = 0; l < thisType.coordinates[k].length; l++) {
//                //xgtlt(thisType.coordinates[j][k][l][0]);
//                //ygtlt(thisType.coordinates[j][k][l][1]); //box check
//                gPolyPoints[m].push(new google.maps.LatLng(thisType.coordinates[k][l][1], thisType.coordinates[k][l][0]));
//            }
//            ;
//        }
//        ;
//    }
//    ;
//
//    if (thisType.type == "MultiPolygon") {
//        for (var j = 0; j < thisType.coordinates.length; j++) {		// j iterates over multipolygons   *-
//            for (var k = 0; k < thisType.coordinates[j].length; k++) {  //k iterates over polygons
//                var m = gPolyPoints.length;
//                gPolyPoints[m] = []; //create a new coordinate/point array for this (m/n) polygon
//                for (var l = 0; l < thisType.coordinates[j][k].length; l++) {
//                    xgtlt(thisType.coordinates[j][k][l][0]);
//                    ygtlt(thisType.coordinates[j][k][l][1]); //box check
//                    gPolyPoints[m].push(new google.maps.LatLng(thisType.coordinates[j][k][l][1], thisType.coordinates[j][k][l][0]));
//                }
//                ;
//            }
//            ;
//        }
//        ;
//    }
//    ;
//};        //getTypeData
//
//
//function createPoint(coords, color) {
//    return new google.maps.Marker({
//        position: coords,
//        map: map
//    });
//};
//
////		function createLine(coords, color) {
////			return new google.maps.Polyline({
////				paths: coords,
////				geodesic: false,
////				strokeColor: "#FF0000",
////				strokeOpacity: 0.5,
////				strokeWeight: 3
////			});
////		};
//
//function createPolygon(coords, color) {
//    return new google.maps.Polygon({
//        paths: coords,
//        strokeColor: "black",
//        strokeOpacity: 0.8,
//        strokeWeight: 1,
//        fillColor: color,
//        fillOpacity: 0.3
//    });
//};

function xgtlt(xtest) {

    if (xtest < 0) {            // if western hemisphere,
        if (xtest > xmaxm) {    // xmaxm initially -180
            xmaxm = xtest;
        }
        if (xtest <= xminm) {   // xminm initially 0
           xminm = xtest;
        }
    }
    if (xtest >= 0) {                  // eastern hemisphere
        if (xtest >= xmaxp) {   // xmaxp initially 0
            xmaxp = xtest;
        }
        if (xtest <= xminp) {   // xminp initially 180
            xminp = xtest;
        }
    }
};

function ygtlt(ytest) {
    if (ytest > ymax) {
        ymax = ytest;
    }
    ;
    if (ytest < ymin) {
        ymin = ytest;
    }
    ;
};

function createPointL(coords, color) {
    return new L.marker(coords, { color: color });
    var marker = L.marker([51.5, -0.09]).addTo(map);
};

//		function createLineL(coords, color) {
//			return new L.Polyline(coords, { color: color });
//		};

function createPolygonL(coords, color) {
    return new L.Polygon(coords, { color: color });
};


