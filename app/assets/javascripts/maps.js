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
var lLinePoints = [];

// bounds for calculating center point
var xmin = 360.0;
var xmax = 0.0;
var ymin = 90.0;
var ymax = -90.0;

// used to center the map in the window
var center_long;
var center_lat;
var center_lat_long;

// zoom level
var gzoom = 4;

var initialize;

initialize = function () {
    // bounds = new google.maps.LatLngBounds();
    get_data();
    get_window_center();

    var myOptions = {
        zoom: gzoom,
        center: center_lat_long,
        mapTypeControl: true,
        mapTypeControlOptions: { style: google.maps.MapTypeControlStyle.DROPDOWN_MENU },
        navigationControl: true,
        mapTypeId: google.maps.MapTypeId.TERRAIN
    };

    initialize_map(myOptions);
    add_shapes_to_map();
};

function initialize_map(options) {
    map = new google.maps.Map(document.getElementById("map_canvas"), options);
}

function get_window_center() {
    if (center_long == undefined) {
        center_long = 0.5 * (xmax + xmin); // - 180.0;
    }
    ;
    if (center_lat == undefined) {
        center_lat = 0.5 * (ymax + ymin);
    }
    ;
    if (xmax > 359.0 && xmin < 1) {
        gzoom = 1.0;
    }
    // center_long =  0.5*(xmax + xmin);
    // center_lat = 0.5*(ymax + ymin);

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
        var n = lLinePoints.length;
        gLinePoints[m] = [];
        lLinePoints[n] = [];
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
            var n = lLinePoints.length;
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
    if (xtest + 180.0 >= xmax) {
        xmax = xtest + 180.0;
    }
    ;
    if (xtest + 180.0 <= xmin) {
        xmin = xtest + 180.0;
    }
    ;
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


