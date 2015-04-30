var _init_match_georeference_page_widget;

_init_match_georeference_page_widget = function init_match_georeference_page() {
    if ($('#match_georeference_widget').length) {

        var setup = [];
        //setup = initializeGoogleMapWithDrawManager("#_draw_ce_form");
        //setup = initializeGoogleMapWithDrawManager("#_draw_gr_form");

        $(".filter-ce").click(function (event) {

            // unhide this form
            $("#_filter_ce_form").removeAttr("hidden");
            // hide everything else:  tag; drawing; recent;
            $("#_tag_ce_form").attr("hidden", true);
            $("#_draw_ce_form").attr("hidden", true);
            $("#_recent_ce_form").attr("hidden", true);
            $('#_selecting_ce_form').attr('hidden', true);

            event.preventDefault();
        });
        // this DOM object represents the form for retrieving the filtering data for
        // selecting collecting events. In this case
        //      div.id = '_filter_ce_form'
        //      form.id = 'filtering_data'
        $("#filtering_ce_data").on("ajax:success", function (e, data, status, local_data) {
            // make a local object of the selecting form so we can use it later
            var selecting = $('#_selecting_ce_form');
            // see what the message was, if anything
            var message = local_data.responseJSON['message'];
            if (message.length) {
                selecting.html(message);
            }
            else {
                // shove the returning html into the local form
                selecting.html(local_data.responseJSON['html']);
                // hide the filter div
                $("#_filter_ce_form").attr("hidden", true);
            }
            // unhide the local div
            selecting.removeAttr('hidden');
            return true;
        }).on("ajax:error", function (e, xhr, status, error) {
            $("#new_article").append("<p>ERROR</p>");
        });

        $(".tag-ce").click(function (event) {

            // unhide this form
            $("#_tag_ce_form").removeAttr("hidden");
            // hide everything else: filter; drawing; recent;
            $("#_filter_ce_form").attr("hidden", true);
            $("#_draw_ce_form").attr("hidden", true);
            $("#_recent_ce_form").attr("hidden", true);
            $('#_selecting_ce_form').attr('hidden', true);

            event.preventDefault();
        });
        // this DOM object represents the form for retrieving the keyword for
        // selecting collecting events. In this case
        //      div.id = '_tag_ce_form'
        //      form.id = 'tagged_ce_keyword'
        $("#tagged_ce_keyword").on("ajax:success", function (e, data, status, local_data) {
            // make a local object of the selecting form so we can use it later
            var selecting = $('#_selecting_ce_form');
            // see what the message was, if anything
            var message = local_data.responseJSON['message'];
            // shove the returning html into the local form
            selecting.html(local_data.responseJSON['html']);
            // hide the filter div
            $("#_tag_ce_form").attr("hidden", true);
            // unhide the local div
            selecting.removeAttr('hidden');
            return true;
        }).on("ajax:error", function (e, xhr, status, error) {
            $("#new_article").append("<p>ERROR</p>");
        });

        $(".draw-ce").click(function (event) {

            // unhide this form
            $("#_draw_ce_form").removeAttr("hidden");
            // hide everything else: filter; tag; recent;
            $("#_filter_ce_form").attr("hidden", true);
            $("#_tag_ce_form").attr("hidden", true);
            $("#_recent_ce_form").attr("hidden", true);
            $('#_selecting_ce_form').attr('hidden', true);

            setup = initializeGoogleMapWithDrawManager("#_draw_ce_form");

            event.preventDefault();
        });

        $(".recent-ce").click(function (event) {

            // unhide this form
            $("#_recent_ce_form").removeAttr("hidden");
            // hide everything else: filter; tag; drawing;
            $("#_filter_ce_form").attr("hidden", true);
            $("#_tag_ce_form").attr("hidden", true);
            $("#_draw_ce_form").attr("hidden", true);
            $('#_selecting_ce_form').attr('hidden', true);

            event.preventDefault();
        });

        $("#recent_ce_count").on("ajax:success", function (e, data, status, local_data) {
            var selecting = $('#_selecting_ce_form');
            // see what the message was, if anything
            var message = local_data.responseJSON['message'];
            selecting.html(local_data.responseJSON['html']);
            $("#_recent_ce_form").attr("hidden", true);
            selecting.removeAttr('hidden');
            return true;
        }).on("ajax:error", function (e, xhr, status, error) {
            $("#new_article").append("<p>ERROR</p>");
        });

        //$("#submit_recent_ce").click(function (event) {
        //   // $('#how_many').val($('#how_many_recent').val());
        //    var extra = $('form#recent_ce_count').serialize();
        //    $.get('recent_ce_collecting_events', extra, function (local_data) {
        //        // what to do with the json we get back....
        //        $("#_recent_ce_form").attr("hidden", true);
        //        var selecting = $('#_selecting_ce_form');
        //        selecting.removeAttr('hidden');
        //        selecting.html(local_data['html']);
        //    });
        //
        //    event.preventDefault();
        //});

        $(".filter-gr").click(function (event) {

            // unhide this form
            $("#_filter_gr_form").removeAttr("hidden");
            // hide everything else:  tag; drawing; recent;
            $("#_tag_gr_form").attr("hidden", true);
            $("#_draw_gr_form").attr("hidden", true);
            $("#_recent_gr_form").attr("hidden", true);
            $('#_selecting_gr_form').attr('hidden', true);

            event.preventDefault();
        });

        $(".tag-gr").click(function (event) {

            // unhide this form
            $("#_tag_gr_form").removeAttr("hidden");
            // hide everything else: filter; drawing; recent;
            $("#_filter_gr_form").attr("hidden", true);
            $("#_draw_gr_form").attr("hidden", true);
            $("#_recent_gr_form").attr("hidden", true);
            $('#_selecting_gr_form').attr('hidden', true);

            event.preventDefault();
        });
        // this DOM object represents the form for retrieving the keyword for
        // selecting collecting events. In this case
        //      div.id = '_tag_gr_form'
        //      form.id = 'tagged_gr_keyword'
        $("#tagged_gr_keyword").on("ajax:success", function (e, data, status, local_data) {
            // make a local object of the selecting form so we can use it later
            var selecting = $('#_selecting_gr_form');
            // see what the message was, if anything
            var message = local_data.responseJSON['message'];
            // shove the returning html into the local form
            selecting.html(local_data.responseJSON['html']);
            // hide the filter div
            $("#_tag_gr_form").attr("hidden", true);
            // unhide the local div
            selecting.removeAttr('hidden');
            // start the map process
            setup = initializeMap($("#_select_gr_form").data('map-canvas'), $("#_select_gr_form").data('feature-collection'));
            add_match_georeferences_map_listeners(setup);
            return true;
        }).on("ajax:error", function (e, xhr, status, error) {
            $("#new_article").append("<p>ERROR</p>");
        });

        $(".draw-gr").click(function (event) {

            // unhide this form
            $("#_draw_gr_form").removeAttr("hidden");
            // hide everything else: filter; tag; recent;
            $("#_filter_gr_form").attr("hidden", true);
            $("#_tag_gr_form").attr("hidden", true);
            $("#_recent_gr_form").attr("hidden", true);
            $('#_selecting_gr_form').attr('hidden', true);

            setup = initializeGoogleMapWithDrawManager("#_draw_gr_form");

            event.preventDefault();
        });

        $(".recent-gr").click(function (event) {

            // unhide this form
            $("#_recent_gr_form").removeAttr("hidden");
            // hide everything else: filter; tag; drawing;
            $("#_filter_gr_form").attr("hidden", true);
            $("#_tag_gr_form").attr("hidden", true);
            $("#_draw_gr_form").attr("hidden", true);
            $('#_selecting_gr_form').attr('hidden', true);

            event.preventDefault();
        });

        $("#recent_gr_count").on("ajax:success", function (e, data, status, local_data) {
            var selecting = $('#_selecting_gr_form');
            // see what the message was, if anything
            var message = local_data.responseJSON['message'];
            if (message.length) {
                selecting.html(message);
            }
            else {
                selecting.html(local_data.responseJSON['html']);
                $("#_recent_gr_form").attr("hidden", true);
                setup = initializeMap($("#_select_gr_form").data('map-canvas'), $("#_select_gr_form").data('feature-collection'));
                add_match_georeferences_map_listeners(setup);
            }
            selecting.removeAttr('hidden');
            return true;
        }).on("ajax:error", function (e, xhr, status, error) {
            $("#new_article").append("<p>ERROR</p>");
        });


        // this is the find submits ajax request, get's FC response and draws it on the map

        // within above, bind click events to copy FC item to FC item
        // setup = initializeGoogleMapWithDrawManager("#_draw_ce_form");

    }
};

$(document).ready(_init_match_georeference_page_widget);
$(document).on("page:load", _init_match_georeference_page_widget);

$(function () {
    $("#st_datepicker").datepicker();
});
// https://api.jqueryui.com/datepicker/
//# This makes the pop-up show the actual db date by fixing a format difference.
$(function () {
    var dateInput = $("#st_datepicker");
    var format = 'dd-MM-yy';
    dateInput.datepicker({dateFormat: format});
    dateInput.datepicker('setDate', $.datepicker.parseDate(format, dateInput.val()));
});

$(function () {
    $("#en_datepicker").datepicker();
});
// https://api.jqueryui.com/datepicker/
//# This makes the pop-up show the actual db date by fixing a format difference.
$(function () {
    var dateInput = $("#en_datepicker");
    var format = 'yy-mm-dd';
    dateInput.datepicker({dateFormat: format});
    dateInput.datepicker('setDate', $.datepicker.parseDate(format, dateInput.val()));
});

function add_click_services_to_match_georeferences_map(map, event) {     // click event passed in
    // captures and displays map coordinates from click event thru asserted_distribution/new.html.erb..span:map_coords
    // checks for preemptive condition
    // requests and displays choices from asserted_distribution_controller thru .../new...span:qnadf
    // clears previous map data features
    // sets mouseover/mouseout behavior for buttons via forEach(function(feature))
    //   in map.data corresponding to "button_nnnn" where nnnn is area id
    // resizes, recenters map based on new features
    /*    var mapLatLng = event.latLng;

     //$("#map_coords").html('Coordinates: Latitude = ' + mapLatLng.lat().toFixed(6) + ' , Longitude = ' + mapLatLng.lng().toFixed(6)) ;
     //if(new_asserted_distribution_check_preemption()) {return;};
     //
     //$("#latitude").val(mapLatLng.lat());
     //$("#longitude").val(mapLatLng.lng());

     $.get( 'generate_choices', $('#_select_gr_form').serialize(), function(local_data) {
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
     */
}


function add_match_georeferences_map_listeners(map) {      // 4 listeners, one for map as a whole 3 for map.data features
    // When the user clicks, set 'isColorful', changing the color of the feature.
    map.data.addListener('click', function (event) {
        if (event.feature.getProperty('isColorful')) {           // reset selected color if
            event.feature.setProperty('isColorful', false);     // previously selected
            event.feature.setProperty('fillColor', "#440000");  // to dimmer red
        }
        else {      // if not already "Colorful", make it so
            event.feature.setProperty('isColorful', true);
            event.feature.setProperty('fillColor', "#CC0000");  //brighter red
        }
        ;
        add_click_services_to_match_georeferences_map(map, event);
    });

    // When the user hovers, tempt them to click by outlining the letters.
    // Call revertStyle() to remove all overrides. This will use the style rules
    // defined in the function passed to setStyle()
    map.data.addListener('mouseover', function (event) {
        map.data.revertStyle();
        map.data.overrideStyle(event.feature, {fillColor: '#880000'});  // mid-level red
        map.data.overrideStyle(event.feature, {strokeWeight: 2});       //embolden borders
    });

    map.data.addListener('mouseout', function (event) {
        map.data.revertStyle();
    });

    google.maps.event.addListener(map, 'click', function (event) {
        add_click_services_to_match_georeferences_map(map, event);
    });
}           // add_listeners end

