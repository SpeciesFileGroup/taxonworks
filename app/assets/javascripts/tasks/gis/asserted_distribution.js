/* 
  javascript for tasks/gis/new
*/

function new_asserted_distribution_check_preemption() {       // page-specific check for postback prerequisites
    if($("[name=asserted_distribution\\[source_id\\]]")[0].value == "") {   // slightly convoluted since name not id
        $("#sourceError").text("Please set a source before selecting an area!");
        return true;
    }
    else {
        $("#sourceError").text("");
        return false;}
}

function add_click_services_to_new_asserted_distribution_map(map, event) {     // click event passed in
    // captures and displays map coordinates from click event thru asserted_distribution/new.html.erb..span:map_coords
    // checks for preemptive condition
    // requests and displays choices from asserted_distribution_controller thru .../new...span:qnadf
    // clears previous map data features
    // sets mouseover/mouseout behavior for buttons via forEach(function(feature))
    //   in map.data corresponding to "button_nnnn" where nnnn is area id
    // resizes, recenters map based on new features
    var mapLatLng = event.latLng;

    $("#map_coords").html('Coordinates: Latitude = ' + mapLatLng.lat().toFixed(6) + ' , Longitude = ' + mapLatLng.lng().toFixed(6)) ;
    if(new_asserted_distribution_check_preemption()) {return;};

    $("#latitude").val(mapLatLng.lat());
    $("#longitude").val(mapLatLng.lng());

    $.get( 'generate_choices', $('form#new_asserted_distribution_from_map_form').serialize(), function(local_data) {
            $("#choices").html(local_data['html']);      // local_data contains html(selection forms)
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
                        //map.data.overrideStyle(this_feature, {fillColor: '#000000'});     //  black
                        map.data.overrideStyle(this_feature, {strokeWeight: 0.0});       // erase borders
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

            var data = local_data['feature_collection'];
            var bounds = {};
            getData(data, bounds);
            var center_lat_long = get_window_center(bounds);
            map.setCenter(center_lat_long);
            map.setZoom(bounds.gzoom);
            //map.fitBounds(bounds.box);
        },
        'json' // I expect a JSON response
    );
}


function add_new_asserted_distribution_map_listeners(map) {      // 4 listeners, one for map as a whole 3 for map.data features
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
        add_click_services_to_new_asserted_distribution_map(map, event);
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
        add_click_services_to_new_asserted_distribution_map(map, event);
    });
}           // add_listeners end


var _init_asserted_distributions_map;

_init_asserted_distributions_map = function init_asserted_distributions_map() {
    if ($("#new_asserted_distribution_map_canvas").length) {
        if (document.getElementById('feature_collection') != null) {
            var newadwidget = $("#feature_collection");
            var fcdata = newadwidget.data('feature-collection');
//    alert(fcdata);
            var map = initializeMap("new_asserted_distribution_map_canvas", fcdata); // fcdata
            add_new_asserted_distribution_map_listeners(map);
        }
    }
}
$(document).ready(_init_asserted_distributions_map);
$(document).on("page:load", _init_asserted_distributions_map);
