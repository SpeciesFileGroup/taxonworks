/* Basic library to parse through TW returned geoJSON and draw a polygon on a Google Map.  
 * Lots of optimization etc. possible down the road.
 *
 */

var map;	// google map object
var data; // TaxonWorks jSON data

var gPoints = [];		//googlemaps arrays
var gLinePoints = [];
var gPolyPoints = [];

var lPoints = [];

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
var gzoom = 0;

var initialize;

initialize = function () {
    // bounds = new google.maps.LatLngBounds();
    //get_data();
    //get_window_center();

    var myOptions = {
        zoom: gzoom,
        center: {lat:40, lng: 0}, //center_lat_long, set to 0,0
        mapTypeControl: true,
        mapTypeControlOptions: { style: google.maps.MapTypeControlStyle.DROPDOWN_MENU },
        navigationControl: true,
        mapTypeId: google.maps.MapTypeId.TERRAIN
    };

    initialize_map(myOptions);
    //add_shapes_to_map();      // old home-brew interpreter and range/bounds/center function
    if (data["type"] != "Feature" && data["type"] != "FeatureCollection") {     // forgive older style JSON without Feature, etc.
        datastring = JSON.stringify(data);
        datastring = '{ "type": "Feature", "geometry": ' + datastring + '}';
        datafeature = JSON.parse(datastring);
        data = datafeature;
    }
        map.data.setStyle({fillColor: '#880000', strokeOpacity: 0.5, strokeWeight: 1, fillOpacity: 0.3})
        map.data.addGeoJson(data);

        centerofmap = map.getCenter();      // not getting desired result
        map.setMap(map);

};

function initialize_map(options) {
    map = new google.maps.Map(document.getElementById("map_canvas"), options);
}

function get_window_center() {
    if (center_long == undefined) {
        //determine case of area extent
        center_long = 0.0;
        wm = 0.0;        // western hemisphere default area width
        wp = 0.0;        // eastern hemisphere default area width
        if (xmaxm >= xminm) {wm = xmaxm - xminm}    // width of western area, if present
        if (xmaxp >= xminp) {wp = xmaxp - xminp}    // width of eastern area, if present
        wx = wm + wp;                               // total width of "contiguous" area
        if ((xmaxm > -180.0) && (xminp < 180.0)) {               // covers GB, and any non-crossing +/-180
            //wp = xmaxp;             // width of eastern side
            //wm = -xminm;  //seems wrong
            if (wp >= wm) {center_long = xmaxp - 0.5 * (wp + wm)}     // then favor eastern hemisphere
            if (wp < wm) {center_long = xminm + 0.5 * (wp + wm)}     // then favor western hemisphere
            //center_long = 0.5 * (xmaxp + xminm);            //get the mean about 0
        }
        else if ((xmaxp > 179.0) && (xminm < -179.0)) {     // covers USA and Russia == overlap +/- 180
            //wp = 180.0 - xminp;
            //wm = -(-180 -xmaxm);
            if (wp > wm) {center_long = xminp - 0.5 * (wp + wm)}     // then favor eastern hemisphere
            if (wp < wm) {center_long = xmaxm + 0.5 * (wp + wm)}     // then favor western hemisphere

            //center_long = 0.5 * (xmaxm - xmaxp);           // bias to
        }
        else if ((xminp > 0.0) && (xmaxp < 180.0) && (xminp < xmaxp)) {  // if not wall-to-wall and has (ALL) eastern content
            center_long = 0.5 * (xmaxp + xminp);             //get the mean -- this computation assumes -180 is next to +180
        }
        else if ((xminm > -180.0) && (xmaxm < 0.0) && (xmaxm > xminm)) {  // if not wall-to-wall and has (ALL) western content
            center_long = 0.5 * (xmaxm + xminm);             //get the mean -- this computation assumes -180 is next to +180
        };
    }
    ;
    if (center_lat == undefined) {
        center_lat = 0.5 * (ymax + ymin);
    }
    ;
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
    if (wx > 160.0) {gzoom = 1};
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

function get_data() {
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
};

// detect and extract geometry types from higher level enumerator, recursible
function getTypeData(thisType) {

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
        gPoints.push(new google.maps.LatLng(thisType.coordinates[1], thisType.coordinates[0]));
    }
    ;

    if (thisType.type == "MultiPoint") {
        for (var l = 0; l < thisType.coordinates.length; l++) {
            //xgtlt(thisType.coordinates[j][k][l][0]);
            //ygtlt(thisType.coordinates[j][k][l][1]); //box check
            gPoints.push(new google.maps.LatLng(thisType.coordinates[l][1], thisType.coordinates[l][0]));
        }
        ;
    }
    ;

    if (thisType.type == "LineString") {
        var m = gLinePoints.length;
        gLinePoints[m] = [];
        for (var l = 0; l < thisType.coordinates.length; l++) {
            //xgtlt(thisType.coordinates[j][k][l][0]);
            //ygtlt(thisType.coordinates[j][k][l][1]); //box check
            gLinePoints[m].push(new google.maps.LatLng(thisType.coordinates[l][1], thisType.coordinates[l][0]));
        }
        ;
    }
    ;

    if (thisType.type == "MultiLineString") {
        for (var k = 0; k < thisType.coordinates.length; k++) {   //k enumerates linestrings, l enums points
            var m = gLinePoints.length;
            gLinePoints[m] = [];
            for (var l = 0; l < thisType.coordinates[k].length; l++) {
                //xgtlt(thisType.coordinates[j][k][l][0]);
                //ygtlt(thisType.coordinates[j][k][l][1]); //box check
                gLinePoints[m].push(new google.maps.LatLng(thisType.coordinates[k][l][1], thisType.coordinates[k][l][0]));
            }
            ;
        }
        ;
    }
    ;

    if (thisType.type == "Polygon") {
        for (var k = 0; k < thisType.coordinates.length; k++) {
            // k enumerates polygons, l enumerates points
            var m = gPolyPoints.length;
            gPolyPoints[m] = [];		//create a new coordinate/point array for this (m/n) polygon
            for (var l = 0; l < thisType.coordinates[k].length; l++) {
                //xgtlt(thisType.coordinates[j][k][l][0]);
                //ygtlt(thisType.coordinates[j][k][l][1]); //box check
                gPolyPoints[m].push(new google.maps.LatLng(thisType.coordinates[k][l][1], thisType.coordinates[k][l][0]));
            }
            ;
        }
        ;
    }
    ;

    if (thisType.type == "MultiPolygon") {
        for (var j = 0; j < thisType.coordinates.length; j++) {		// j iterates over multipolygons   *-
            for (var k = 0; k < thisType.coordinates[j].length; k++) {  //k iterates over polygons
                var m = gPolyPoints.length;
                gPolyPoints[m] = []; //create a new coordinate/point array for this (m/n) polygon
                for (var l = 0; l < thisType.coordinates[j][k].length; l++) {
                    xgtlt(thisType.coordinates[j][k][l][0]);
                    ygtlt(thisType.coordinates[j][k][l][1]); //box check
                    gPolyPoints[m].push(new google.maps.LatLng(thisType.coordinates[j][k][l][1], thisType.coordinates[j][k][l][0]));
                }
                ;
            }
            ;
        }
        ;
    }
    ;
};        //getTypeData


function createPoint(coords, color) {
    return new google.maps.Marker({
        position: coords,
        map: map
    });
};

//		function createLine(coords, color) {
//			return new google.maps.Polyline({
//				paths: coords,
//				geodesic: false,
//				strokeColor: "#FF0000",
//				strokeOpacity: 0.5,
//				strokeWeight: 3
//			});
//		};

function createPolygon(coords, color) {
    return new google.maps.Polygon({
        paths: coords,
        strokeColor: "black",
        strokeOpacity: 0.8,
        strokeWeight: 1,
        fillColor: color,
        fillOpacity: 0.3
    });
};

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


