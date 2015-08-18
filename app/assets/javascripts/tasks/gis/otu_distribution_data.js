var _init_otu_distribution_data_widget;
_init_otu_distribution_data_widget = function init_otu_distribution_data() {
  if ($('#otu_distribution_widget').length) {
    if (document.getElementById('_displayed_distribution_form') != null) {
      var newfcdata = $("#_displayed_distribution_form");
      var fcdata = newfcdata.data('feature-collection');
      var map_canvas = newfcdata.data('map-canvas');


      var otu_map = initializeMap(map_canvas, fcdata);
      add_otu_distribution_data_listeners(otu_map);

      $('input[type="checkbox"]').change(function () {    // on checkbox change, reset to original feature data
        otu_map = initializeMap(map_canvas, newfcdata.data('feature-collection'));
        add_otu_distribution_data_listeners(otu_map);
      });
    }
  }
};

function add_otu_distribution_data_listeners(map) {
  var this_id = this.id;
  var otu_id = 1; //this_id.slice(7,this_id.length);      // 'button_'.length, 'button_abc...xyz'.length


  $("[id^=span_]").mouseover(function () {
    var this_id = this.id;
    var split1 =  this_id.split('span_');
    var split2 = split1[1].split("_otu_id_");
    var this_type = split2[0];
    var otu_id = split2[1]; //this_id.slice(7,this_id.length);      // 'button_'.length, 'button_abc...xyz'.length
    addMouseoverListenerForOtuSpans(otu_id, this_type, map);
  });

  $("[id^=span_]").mouseout(function () {
    var this_id = this.id;
    var split1 =  this_id.split('span_');
    var split2 = split1[1].split("_otu_id_");
    var this_type = split2[0];
    var otu_id = split2[1]; //this_id.slice(7,this_id.length);      // 'button_'.length, 'button_abc...xyz'.length
    map.data.forEach(function (feature) {        // find by ??
      map.data.revertStyle();
    }
    );
    }
  );

  //$("[id^=check_collecting_event_georeference_]").mouseover(function () {
  //  var this_id = this.id;
  //  var otu_id = 1; //this_id.slice(7,this_id.length);      // 'button_'.length, 'button_abc...xyz'.length
  //  addListenerForCheckboxes(otu_id, map);
  //});
  //
  //$("[id^=check_collecting_event_geographic_area_]").mouseover(function () {
  //  var this_id = this.id;
  //  var otu_id = 1; //this_id.slice(7,this_id.length);      // 'button_'.length, 'button_abc...xyz'.length
  //  addListenerForCheckboxes(otu_id, type,  map);
  //});

  map.data.addListener('click', function (event) {
    map.data.revertStyle();
    map.data.overrideStyle(event.feature, {fillOpacity: 0.5});
    //$("#displayed_distribution_style").html(event.feature.getProperty('metadata').Source.type);
    document.getElementById("displayed_distribution_style").textContent = event.feature.getProperty('source');
    var xx = 0;
  });

  map.data.addListener('mouseover', function (event) {     // interim color shift on mousover paradigm changed to opacity
    map.data.revertStyle();
    map.data.overrideStyle(event.feature, {fillOpacity: 1.0});  // bolder
    map.data.overrideStyle(event.feature, {icon: '/assets/mapicons/mm_20_white.png'});       // highlight markers
    //if (event.feature.getProperty('label') != undefined) {
    document.getElementById("displayed_distribution_style").textContent = event.feature.getProperty('label');
    //$("#displayed_distribution_style").html(event.feature.getProperty('label'));
    //}
  });

  map.data.addListener('mouseout', function (event) {
    map.data.revertStyle();
    //map.data.overrideStyle(event.feature, {fillOpacity: 0.3});  // dimmer
    $("#displayed_distribution_style").html('<br />');
  });
}


function addMouseoverListenerForOtuSpans(otu_id, type, map) {
  map.data.forEach(function (feature) {        // find by ??

      var this_feature = feature;
      var this_object = (this_feature.getProperty('source_type'));
      var this_otu_id = (this_feature.getProperty('otu_id'));
      //
      ///// qualify by type as well, may need more drilling info for access to otu_id
      //
        if(this_otu_id != otu_id) {
        map.data.overrideStyle(this_feature, {strokeWeight: 0.0});       // erase borders
        map.data.overrideStyle(this_feature, {fillOpacity: 0.0});       // transparent
          map.data.overrideStyle(this_feature, {icon: '/assets/mapicons/mm_20_shadow.png'});
      }
      if (this_otu_id == otu_id) {
        if (this_object == type) {
          map.data.overrideStyle(this_feature, {fillOpacity: 1.0});       // saturate
         // map.data.overrideStyle(this_feature, {icon: '/assets/mapicons/mm_20_white.png'});       // highlight markers
        }
      }
    }
  );
}
$(document).ready(_init_otu_distribution_data_widget);
$(document).on("page:load", _init_otu_distribution_data_widget);

//google.maps.event.addDomListener(window, 'load', init_otu_distribution_data);
