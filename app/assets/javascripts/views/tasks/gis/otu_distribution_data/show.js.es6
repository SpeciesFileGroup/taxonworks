var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.gis = TW.views.tasks.gis || {};
TW.views.tasks.gis.otu_distribution = TW.views.tasks.gis.otu_distribution || {};

Object.assign(TW.views.tasks.gis.otu_distribution, {

  init: function() {

    init_otu_distribution_data();

    function init_otu_distribution_data() {

        if (document.getElementById('_displayed_distribution_form') != null) {
          var newfcdata = $("#_displayed_distribution_form");
          var fcdata = newfcdata.data('feature-collection');
          var map_canvas = newfcdata.data('map-canvas');

          var otu_map = TW.vendor.lib.google.maps.initializeMap(map_canvas, fcdata);
          add_otu_distribution_data_listeners(otu_map);

          $('input[type="checkbox"]').change(function () {    // on checkbox change, reset to original feature data
            otu_map = TW.vendor.lib.google.maps.initializeMap(map_canvas, newfcdata.data('feature-collection'));
            add_otu_distribution_data_listeners(otu_map);
          });
        }

    };

    function add_otu_distribution_data_listeners(map) {
      var this_id;
      var otu_id;
      var split1;
      var split2;
      var this_type;

      $("[id^=link_otu_]").mouseover(function () {
          this_id = this.id;
          split1 = this_id.split('link_otu_');
          otu_id = split1[1];
          addMouseoverListenerForOtuSpans(otu_id, null, map);
        }
      );

      $("[id^=link_otu_]").mouseout(function () {
          map.data.revertStyle();        // just revert EVERYTHING
        }
      );

      $("[id^=span_]").mouseover(function () {
        this_id = this.id;
        split1 = this_id.split('span_');
        split2 = split1[1].split("_otu_id_");
        this_type = split2[0];
        otu_id = split2[1];
        addMouseoverListenerForOtuSpans(otu_id, this_type, map);
      });

      $("[id^=span_]").mouseout(function () {
          map.data.revertStyle();
        }
      );

      map.data.addListener('click', function (event) {
        map.data.revertStyle();
        map.data.overrideStyle(event.feature, {fillOpacity: 0.5});
        map.data.overrideStyle(event.feature, {icon: TW.vendor.lib.google.maps.mapIcons['black']});       // highlight markers
        document.getElementById("displayed_distribution_style").textContent = event.feature.getProperty('source');
        var xx = 0;
      });

      map.data.addListener('mouseover', function (event) {     // interim color shift on mousover paradigm changed to opacity
        map.data.revertStyle();
        map.data.overrideStyle(event.feature, {fillOpacity: 1.0});  // bolder
        map.data.overrideStyle(event.feature, {icon: TW.vendor.lib.google.maps.mapIcons['white']});       // highlight markers
        //if (event.feature.getProperty('label') != undefined) {
        if (document.getElementById('displayed_distribution_style') != null) {
          document.getElementById("displayed_distribution_style").textContent = event.feature.getProperty('label');
          //$("#displayed_distribution_style").html(event.feature.getProperty('label'));
        //}
        }
      });

      map.data.addListener('mouseout', function (event) {
        map.data.revertStyle();
        $("#displayed_distribution_style").html('<br />');
      });
    }


    function addMouseoverListenerForOtuSpans(otu_id, type, map) {
      map.data.forEach(function (feature) {
          // now serves both spans and links
          var this_feature = feature;
          var this_object = (this_feature.getProperty('source_type'));
          var this_otu_id = (this_feature.getProperty('otu_id'));
          if ((this_otu_id == otu_id) && ((this_object == type) || (type == null))) {   // if type is specified, qualify by type as well
            map.data.overrideStyle(this_feature, {fillOpacity: 1.0});       // saturate
            //map.data.overrideStyle(this_feature, {icon: '/assets/map_icons/mm_20_white.png'});       // highlight markers
          }
          else /*if(this_otu_id != otu_id)*/ {
            map.data.overrideStyle(this_feature, {strokeWeight: 0.0});       // erase borders
            map.data.overrideStyle(this_feature, {fillOpacity: 0.0});       // transparent
            map.data.overrideStyle(this_feature, {icon: TW.vendor.lib.google.maps.mapIcons['empty']});
          }
        }
      );
    }
  }
});

$(document).on("turbolinks:load", function() {
  if ($('#otu_distribution_widget').length) {
    TW.vendor.lib.google.maps.loadGoogleMapsAPI().then(function() {
      TW.views.tasks.gis.otu_distribution.init();
    });
  }
});
