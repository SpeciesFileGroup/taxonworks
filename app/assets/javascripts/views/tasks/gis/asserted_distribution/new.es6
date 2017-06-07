/* 
 javascript for tasks/gis/asserted_distribution/new
 */

var TW = TW || {};
TW.tasks = TW.tasks || {};
TW.tasks.gis = TW.tasks.gis || {};
TW.tasks.gis.asserted_distributions = TW.tasks.asserted_distributions || {};

Object.assign(TW.tasks.gis.asserted_distributions, {

    init_asserted_distributions_map: function () {
      if ($("#new_asserted_distribution_map_canvas").length) {
        var map = TW.vendor.lib.google.maps.initializeMap("new_asserted_distribution_map_canvas", null);
        TW.tasks.gis.asserted_distributions.add_new_asserted_distribution_map_listeners(map);
      }
    },

    // TODO Rich- move this to general JS libraries
    clear_map: function (map) {
      map.data.forEach(function (feature) {
        map.data.remove(feature);
      });
    },

    // TODO: Rich move this to the general maps library
    get_canvas_bounds: function (map) {
      // original map canvas parameters are now lost, so we have to find them again
      var bounds = {};
      let canvas = map.data.map.getDiv();
      bounds.canvas_width = canvas.style.width.toString().split('px')[0];
      bounds.canvas_height = canvas.style.height.toString().split('px')[0];
      bounds.canvas_ratio = bounds.canvas_width / bounds.canvas_height;
      return bounds
    },

    // prevent map click action if otu and source are not selected
    new_asserted_distribution_check_preemption: function () {
      // add_listeners end
      var source = "[name=asserted_distribution\\[origin_citation_attributes\\]\\[source_id\\]]"
      var otu = "[name=asserted_distribution\\[otu_id\\]]"

      if ($(source)[0].value == "") {
        $("#source_error").show();
        return true;
      }

      if ($(otu)[0].value == "") {
        $("#otu_error").show();
        return true;
      }

      $("#source_error").hide();
      $("otu_error").hide();
      return false;
    },

    bind_create_buttons: function () {
      $("[id^=button_]").click(function () {        // set mouseout for each area (condensed)
        var form = $("#new_asserted_distribution_from_map_form");
        form.append($('<input hidden name="asserted_distribution[geographic_area_id]" value="' + $(this).data('geographic-area-id') + '">'));
      });
    },

    bind_mouseover: function (map) {
      $("[id^=button_]").mouseover(function () {       // set mouseover for each area
        var this_id = this.id;
        var area_id = $(this).data('geographic-area-id');
        map.data.forEach(function (feature) {        // find by geographic area id
          var this_feature = feature;
          var this_property = this_feature.getProperty('geographic_area');
          if (this_property.id != area_id) {
            map.data.overrideStyle(this_feature, {strokeWeight: 0.0});      // erase borders
            map.data.overrideStyle(this_feature, {fillOpacity: 0.0});       // transparent
          }
          if (this_property.id == area_id) {
            map.data.overrideStyle(this_feature, {fillColor: '#FF0000'});  // red
            map.data.overrideStyle(this_feature, {strokeWeight: 2});       // embolden borders
            map.data.overrideStyle(this_feature, {fillOpacity: 1.0});      // transparent
          }
        });
      });
    },

    bind_mouseout: function (map) {
      $("[id^=button_]").mouseout(function () {        // set mouseout for each area (condensed)
        var this_id = this.id;                      // var this since it goes out of scope with .forEach
        map.data.forEach(function (feature) {        // find by geographic area id
          if (feature.getProperty('geographic_area').id == $(this).data('geographic-area-id')) {
            map.data.revertStyle();
          }
        });
      });
    },

    // present and configure choices when the map is clicked
    add_click_services_to_new_asserted_distribution_map: function (map, event) {     // click event passed in

      // checks for preemptive condition
      if (this.new_asserted_distribution_check_preemption()) {
        return;
      }
      ;

      var mapLatLng = event.latLng;
      $("#latitude").val(mapLatLng.lat());
      $("#longitude").val(mapLatLng.lng());

      $("#choices").mx_spinner('show');

      // requests and displays choices from asserted_distribution_controller thru .../new...span:qnadf
      $.get('generate_choices', $('form#new_asserted_distribution_from_map_form').serialize(), 'json')
        .done(function (local_data) {
          var data = local_data['feature_collection'];

          $("#choices").mx_spinner('hide');

          // render the choices (html)
          $("#choices").html(local_data['html']);

          TW.tasks.gis.asserted_distributions.bind_create_buttons();
          TW.tasks.gis.asserted_distributions.clear_map(map);          // clears previous map data features

          map.data.addGeoJson(data);      // add the geo features corresponding to the forms

          TW.tasks.gis.asserted_distributions.bind_mouseover(map);
          TW.tasks.gis.asserted_distributions.bind_mouseout(map);

          // resizes, recenters map based on new features

          // TODO: all of the following code should be in general maps library
          //       called something like TW.vendor.lib.google.maps.bound_and_recenter(map, feature_collection)
          // TODO: where the hell is feature_collection getting initialized?!
          var bounds = TW.tasks.gis.asserted_distributions.get_canvas_bounds(map);

          // TODO: new bounds is not working, because feature_collection is undefined
          TW.vendor.lib.google.maps.getData(data, bounds);
          var center_lat_long = TW.vendor.lib.google.maps.get_window_center(bounds);
          map.setCenter(center_lat_long);
          map.setZoom(bounds.gzoom);
        });
    },

    add_new_asserted_distribution_map_listeners: function (map) {      // 4 listeners, one for map as a whole 3 for map.data features
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
        TW.tasks.gis.asserted_distributions.add_click_services_to_new_asserted_distribution_map(map, event);
      });

      // When the user hovers, tempt them to click by outlining the letters.
      // Call revertStyle() to remove all overrides. This will use the style rules
      // defined in the function passed to setStyle()
      map.data.addListener('mouseover', function (event) {
        map.data.revertStyle();
        map.data.overrideStyle(event.feature, {fillColor: '#880000'});  // mid-level red
        map.data.overrideStyle(event.feature, {strokeWeight: 2});       //embolden borders
        map.data.overrideStyle(event.feature, {icon: TW.vendor.lib.google.maps.mapIcons['brown']});       // highlight markers
      });

      map.data.addListener('mouseout', function (event) {
        map.data.revertStyle();
      });

      google.maps.event.addListener(map, 'click', function (event) {
        TW.tasks.gis.asserted_distributions.add_click_services_to_new_asserted_distribution_map(map, event);
      });
    },

    //created to isolate functions above and debug mouseover
    add_mouseOver_Out_listeners: function (map) {
      // When the user clicks, set 'isColorful', changing the color of the feature.
      map.data.addListener('click', function (event) {
        if (event.feature.getProperty('isColorful')) {        // reset selected color if
          event.feature.setProperty('isColorful', false);     // previously selected
          event.feature.setProperty('fillColor', "#440000");  // to dimmer red
        }
        else {      // if not already "Colorful", make it so
          event.feature.setProperty('isColorful', true);
          event.feature.setProperty('fillColor', "#CC0000");  //brighter red
        }
        ;
      });

      map.data.addListener('mouseover', function (event) {
        map.data.revertStyle();
        map.data.overrideStyle(event.feature, {fillColor: '#880000'});  // mid-level red
        map.data.overrideStyle(event.feature, {strokeWeight: 2});       //embolden borders
        map.data.overrideStyle(event.feature, {icon: TW.vendor.lib.google.maps.mapIcons['brown']});       // highlight markers
      });

      map.data.addListener('mouseout', function (event) {
        map.data.revertStyle();
      });
    }
  }
); // end widget

$(document).ready(TW.tasks.gis.asserted_distributions.init_asserted_distributions_map);

