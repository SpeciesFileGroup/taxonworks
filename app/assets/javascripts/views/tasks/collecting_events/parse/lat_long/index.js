var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.collecting_events = TW.views.tasks.collecting_events || {};
TW.views.tasks.collecting_events.parse = TW.views.tasks.collecting_events.parse || {};

Object.assign(TW.views.tasks.collecting_events.parse, {

  init: function () {
    var start_next = 0;
    TW.views.tasks.collecting_events.parse.bind_radio_buttons(); 
  },

  bind_radio_buttons: function () {
    $('.select_lat_long').click( function() {
      // selector not working
      var long = $(this).parent('.extract_row').children('.longitude_value').eq(0).text;
      var lat =  $(this).parent('.extract_row').children('.latitude_value').text('asfasdf');
      alert(lat);  
    });
  }
}

);

$(document).ready(function () {
  if ($("#ce_parse_lat_long").length) {
    //  var _init_lat_long_parse = TW.views.tasks.collecting_events.parse;
    // _init_lat_long_parse.init();
    TW.views.tasks.collecting_events.parse.init();
  }
});
