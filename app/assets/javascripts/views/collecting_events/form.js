var TW = TW || {};
TW.views = TW.views || {};
TW.views.collecting_events = TW.views.collecting_events || {};
TW.views.collecting_events.form = TW.views.collecting_events.form || {};

Object.assign(TW.views.collecting_events.form, {

  init: function() {
    var src = 'https://paleobiodb.org/data1.2/strata/auto.json';

    // https://paleobiodb.org/data1.2/strata/list_doc.html
    // documentation states 'member' is valid, response says it is not
    var fields = ['formation', 'group']; //  ,'member'

    fields.forEach(function(n) {
      $('#' + n).autocomplete({
        close: function( event, ui) { 
          $(this).removeClass('ui-autocomplete-loading'); 
        },
        source: function(request, response) {
          $.ajax({
            url:src,
            data: {
              name : request.term,
              rank: n,
              limit: '30',
              vocab: 'pbdb'
            },
            success: function(data) {
              var names = [];
              $.each(data['records'], function(i, item) {
                names.push(item.name);
              });
              $('#' + n).removeClass("ui-autocomplete-loading");
              response(names);
            },
            error: function() {
              $('#' + n).removeClass("ui-autocomplete-loading");
            }
          });
        },     
        min_length: 2,
      });
    });
  }
  
});

$(document).on('turbolinks:load', function() {
  if($("#collecting_event_form").length) {

    var _init_index = TW.views.collecting_events.form;
		_init_index.init();
	}
});
