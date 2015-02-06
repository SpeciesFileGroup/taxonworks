/* Basic library to parse through TW returned geoJSON and draw a FeatureCollection on a Google Map.
 *
 * Overly integrated with asserted distributions,
 */

var map;	// google map object
var data; // TaxonWorks jSON data object

// bounds for calculating center point
// divide longitude checks by hemisphere
// variables below used by stripped-down get_Data to compute bounds
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

    var myOptions = {
        zoom: gzoom,
        center: {lat:0, lng: 0}, //center_lat_long, set to 0,0
        mapTypeControl: true,
        mapTypeControlOptions: { style: google.maps.MapTypeControlStyle.DROPDOWN_MENU },
        navigationControl: true,
        mapTypeId: google.maps.MapTypeId.TERRAIN
    };

    initialize_map(myOptions);

    map.data.setStyle({fillColor: '#440000', strokeOpacity: 0.5, strokeColor: "black", strokeWeight: 1, fillOpacity: 0.3});
    map.data.addGeoJson(data);

    get_Data();               // scan var data as feature collection with homebrew traverser, collecting bounds
    get_window_center();      // compute center_lat_long from bounds and compute zoom level as gzoom
    $("#map_coords").html('Center: \xA0 \xA0 \xA0 \xA0Latitude = ' + center_lat.toFixed(6) + ' , Longitude = ' + center_long.toFixed(6)) ;
    map.setCenter(center_lat_long);
    map.setZoom(gzoom);

    map.data.setStyle(function(feature) {
        var color = '#440000';  // dimmer red as default feature color
        if (feature.getProperty('isColorful')) {        // isColorful property signals this area/feature was clicked
            color = feature.getProperty('fillColor');   //
        }
        return /** @type {google.maps.Data.StyleOptions} */({
            fillColor: color,
            strokeColor: "black",
            strokeWeight: 1
        });
    });
    add_map_listeners();
};

function initialize_map(options) {
    map = new google.maps.Map(document.getElementById("map_canvas"), options);
}

function add_map_listeners() {      // 4 listeners, one for map as a whole 3 for map.data features
    // When the user clicks, set 'isColorful', changing the color of the feature.
    map.data.addListener('click', function(event) {
        if(event.feature.getProperty('isColorful')) {           // reset selected color if
            event.feature.setProperty('isColorful', false);     // previously selected
            event.feature.setProperty('fillColor', "#440000");  // to dimmer red
        }
        else {      // if not already "Colorful", make it so
            event.feature.setProperty('isColorful', true);
            event.feature.setProperty('fillColor', "#CC0000");  //brighter red
        };
        addClickServicesListeners(event);
    });

    // When the user hovers, tempt them to click by outlining the letters.
    // Call revertStyle() to remove all overrides. This will use the style rules
    // defined in the function passed to setStyle()
    map.data.addListener('mouseover', function(event) {
        map.data.revertStyle();
        map.data.overrideStyle(event.feature, {fillColor: '#880000'});  // mid-level red
        map.data.overrideStyle(event.feature, {strokeWeight: 2});       //embolden borders
    });

    map.data.addListener('mouseout', function(event) {
        map.data.revertStyle();
    });

    google.maps.event.addListener(map, 'click', function (event) {
        addClickServicesListeners(event);
    });
}           // add_listeners end

function check_preemption() {       // page-specific check for postback prerequisites
    if($("[name=asserted_distribution\\[source_id\\]]")[0].value == "") {   // slightly convoluted since name not id
        $("#sourceError").text(" \xA0 Please set a source before selecting an area !");
        return true;
    }
    else {
        $("#sourceError").text("");
        return false;}
}

function addClickServicesListeners(event) {     // click event passed in
        // captures and displays map coordinates from click event thru asserted_distribution/new.html.erb..span:map_coords
        // checks for preemptive condition
        // requests and displays choices from asserted_distribution_controller thru .../new...span:qnadf
        // clears previous map data features
        // sets mouseover/mouseout behavior for buttons via forEach(function(feature))
        //   in map.data corresponding to "button_nnnn" where nnnn is area id
        // resizes, recenters map based on new features
    var mapLatLng = event.latLng;

    $("#map_coords").html('Coordinates: Latitude = ' + mapLatLng.lat().toFixed(6) + ' , Longitude = ' + mapLatLng.lng().toFixed(6)) ;
    if(check_preemption()) {return;};

    //$("#map_canvas").after('<br />Coordinates: Latitude = ' + mapLatLng.lat().toFixed(6) + ', Longitude = ' + mapLatLng.lng().toFixed(6) + '<br />') ;
    $("#latitude").val(mapLatLng.lat());
    $("#longitude").val(mapLatLng.lng());

    $.get( 'generate_choices', $('form#cadu').serialize(), function(local_data) {
            $("#qnadf").html(local_data['html']);      //local_data contains html(selection forms)
            // quick_new_asserted_distribution_form and feature collection geoJSON
            map.data.forEach(function(feature) {map.data.remove(feature);});    // clear the map.data

            map.data.addGeoJson(local_data['feature_collection']);      // add the geo features corresponding to the forms

            // select buttons of the form: "button_nnnn" with jquery, and bind the listener events

            $("[id^=button_]").mouseover(function() {       // set mouseover for each area
                var this_id = this.id;
                var area_id = this_id.slice(7,this_id.length);      // 'button_'.length, 'button_abc...xyz'.length
                map.data.forEach(function(feature) {        // find by geographic area id
                    //this_feature = map.data.getFeatureById(jj); // not used, 0-reference fault in google maps
                    this_feature = feature;
                    this_property = this_feature.getProperty('geographic_area');
                    if(this_property.id != area_id) {
                        //map.data.getFeatureById(01).getProperty('geographic_area')
                        map.data.overrideStyle(this_feature, {fillColor: '#000000'});  //  black
                        map.data.overrideStyle(this_feature, {strokeWeight: 1});       // erase borders
                        map.data.overrideStyle(this_feature, {fillOpacity: 0.0});       // transparent
                    }
                    if(this_property.id == area_id) {
                        map.data.overrideStyle(this_feature, {fillColor: '#FF0000'});  //  red
                        map.data.overrideStyle(this_feature, {strokeWeight: 2});       //embolden borders
                        map.data.overrideStyle(this_feature, {fillOpacity: 1.0});       // transparent
                    }
                });
            })
            $("[id^=button_]").mouseout(function() {        // set mouseout for each area (condensed)
                var this_id = this.id;                      // var this since it goes out of scope with .forEach
                map.data.forEach(function(feature) {        // find by geographic area id
                    if(feature.getProperty('geographic_area').id == this_id.slice(7,this_id.length)) { map.data.revertStyle(); }
                    // 'button_'.length, 'button_abc...xyz'.length
                });
            })

            data = local_data['feature_collection'];
            get_Data();
            get_window_center();
            map.setCenter(center_lat_long);
            map.setZoom(gzoom);
            //add_map_listeners();
            //map.setMap();
        },
        'json' // I expect a JSON response
    );
}

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
            center_long = xmm;       // "works" since there are so few cases that span
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
        if(Math.abs(center_lat) > 1.0) {        // if vertical center very close to equator
            cutoff = 65.0;
            if (/*Math.abs(center_lat) > 45.0 &&*/ (ymax > cutoff || ymin < -cutoff)) {
                angle = ymax - cutoff;
                if (center_lat < 0) {
                    angle = ymin + cutoff;
                }
                offset = Math.cos((angle /*- center_lat*/) / (180.0 / 3.1415926535));
                offset = 0.1 * (ymax - ymin) / offset;
                center_lat = center_lat + offset;
            };
        };
    };

    if(wy > 0.5 * wx) {wx = wy * 2.0}       // VERY crude proportionality adjustment
    if (wx <= 0.1) {gzoom =11};
    if (wx > 0.1) {gzoom = 10};             // quick and dirty zoom range based on size
    if (wx > 0.2) {gzoom = 9};
    if (wx > 0.5) {gzoom = 8};
    if (wx > 1.0) {gzoom = 7};
    if (wx > 2.5) {gzoom = 6};
    if (wx > 5.0) {gzoom = 5};
    if (wx > 10.0) {gzoom = 4};
    if (wx > 40.0) {gzoom = 3};
    if (wx > 80.0) {gzoom = 2};
    if (wx > 160.0 || (wx + wy) == 0) {gzoom = 1};

    center_lat_long = new google.maps.LatLng(center_lat, center_long);
};


function reset_center_and_bounds() {        // used to
    center_long = undefined;               // clear previous history
    center_lat = undefined;               // so that center is recalculated
    xminp = 180.0;       // use 0
    xmaxp = 0.0;        // to
    xminm = 0.0;       // +/-180-based
    xmaxm = -180.0;   // coordinates for longitude

    ymin = 90.0;    // +/-90 for latitude
    ymax = -90.0;
}

function get_Data() {       //this is the scanner version; no google objects are created
    reset_center_and_bounds();
    //		get data object encoded as geoJSON (deprecated: and disseminate to google (deprecated: and leaflet arrays))
    if (typeof (data) != 'undefined') {
        var dataArray = [];
        if (data instanceof Array) {
        }      // if already an array, then do nothing
        else    // convert it to an array
        {
            dataArray[0] = data;
            data = [];
            data[0] = dataArray[0];
        };
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
                };
            }
            else {
                getTypeData(data[i]);
            };  //data[i].type
        };     //data[i] != undefined
     }        // for i
    };       //data != undefined
 };         //get_Data

function getFeature(thisFeature) {
    getTypeData(thisFeature.geometry);
}

function getTypeData(thisType) {        // this version does not create google objects

    if (thisType.type == "FeatureCollection") {
        for (var i = 0; i < thisType.features.length; i++) {
            if (typeof (thisType.features[i].type) != "undefined") {
                getFeature(thisType.features[i]);		//  recurse if FeatureCollection
            };     //thisType != undefined
        };        //for i
    };

    if (thisType.type == "GeometryCollection") {
        for (var i = 0; i < thisType.geometries.length; i++) {
            if (typeof (thisType.geometries[i].type) != "undefined") {
                getTypeData(thisType.geometries[i]);		//  recurse if GeometryCollection
            };     //thisType != undefined
        };       //for i
    };

    if (thisType.type == "Point") {
        xgtlt(thisType.coordinates[0]);
        ygtlt(thisType.coordinates[1]); //box check
    };

    if (thisType.type == "MultiPoint") {
        for (var l = 0; l < thisType.coordinates.length; l++) {
            xgtlt(thisType.coordinates[l][0]);
            ygtlt(thisType.coordinates[l][1]); //box check
        };
    };

    if (thisType.type == "LineString") {
        for (var l = 0; l < thisType.coordinates.length; l++) {
            xgtlt(thisType.coordinates[l][0]);
            ygtlt(thisType.coordinates[l][1]); //box check
        };
    };

    if (thisType.type == "MultiLineString") {
        for (var k = 0; k < thisType.coordinates.length; k++) {   //k enumerates linestrings, l enums points
            for (var l = 0; l < thisType.coordinates[k].length; l++) {
                xgtlt(thisType.coordinates[k][l][0]);
                ygtlt(thisType.coordinates[k][l][1]); //box check
            };
        };
    };

    if (thisType.type == "Polygon") {
        for (var k = 0; k < thisType.coordinates.length; k++) {
            // k enumerates polygons, l enumerates points
            for (var l = 0; l < thisType.coordinates[k].length; l++) {
                xgtlt(thisType.coordinates[k][l][0]);
                ygtlt(thisType.coordinates[k][l][1]); //box check
            };
        };
    };

    if (thisType.type == "MultiPolygon") {
        for (var j = 0; j < thisType.coordinates.length; j++) {		// j iterates over multipolygons   *-
            for (var k = 0; k < thisType.coordinates[j].length; k++) {  //k iterates over polygons
                for (var l = 0; l < thisType.coordinates[j][k].length; l++) {
                    xgtlt(thisType.coordinates[j][k][l][0]);
                    ygtlt(thisType.coordinates[j][k][l][1]); //box check
                };
            };
        };
    };
};        //getFeatureData


function xgtlt(xtest) {         // point-wise x-bound extender

    if (xtest < 0) {            // if western hemisphere,
        if (xtest > xmaxm) {    // xmaxm initially -180
            xmaxm = xtest;
        }
        if (xtest <= xminm) {   // xminm initially 0
           xminm = xtest;
        }
    };
    if (xtest >= 0) {                  // eastern hemisphere
        if (xtest >= xmaxp) {   // xmaxp initially 0
            xmaxp = xtest;
        }
        if (xtest <= xminp) {   // xminp initially 180
            xminp = xtest;
        }
    };
};

function ygtlt(ytest) {         // point-wise y-bound extender
    if (ytest > ymax) {
        ymax = ytest;
    };
    if (ytest < ymin) {
        ymin = ytest;
    };
};


