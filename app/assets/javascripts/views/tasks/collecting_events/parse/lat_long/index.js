var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.collecting_events = TW.views.tasks.collecting_events || {};

Object.assign(TW.views.tasks.collecting_events, {
    
    
    init: function () {
      var start_next = 0;
      
    }
  }
);

$(document).ready(function () {
  if ($("#ce_parse_lat_long").length) {
    var _init_lat_long_parse = TW.views.tasks.collecting_events;
    _init_lat_long_parse.init();
  }
});
