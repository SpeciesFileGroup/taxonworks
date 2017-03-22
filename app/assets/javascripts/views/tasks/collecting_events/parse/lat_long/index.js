var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.collecting_events = TW.views.tasks.collecting_events || {};
TW.views.tasks.collecting_events.parse = TW.views.tasks.collecting_events.parse || {};

Object.assign(TW.views.tasks.collecting_events.parse, {
  
  init: function () {
    var start_next = 0;
    TW.views.tasks.collecting_events.parse.bind_radio_buttons();
    
    $('#lat_long_convert').click(function (event) {
        // $("#select_area").mx_spinner('show');
        $.get('convert', $("#lat_long_convert_form").serialize(), function (local_data) {
            var popcorn = local_data;
            $("#dd_latitude").val(local_data.lat_piece);
            $("#dd_longitude").val(local_data.long_piece);
            // $("#select_area").mx_spinner('hide');
          }, 'json'  // I expect a json response
        );
        event.preventDefault();
      }
    );
  
    //  $('#lat_long_update_record').click(function (event) {
    // put the this id into the form before serializatiun
    // $('#collecting_event_id').val($('this_collecting_event').text());
    //   $.post('update', $("#lat_long_convert_form").serialize() + "&" + $("#gen_georef_box").serialize());
    //  })
  },
  
  bind_similar_buttons: function () {
    $('#disable_all').click(function (event) {
      // find all the checkboxes in the 'matching_span' and set them to 'checked'
      event.preventDefault();
    });
    $('#save_selected').click(function (event) {
      // don't know exactly what to do here
    })
  },
  
  bind_radio_buttons: function () {
    $('.select_lat_long').click(function () {
      // selector not working
      var long = $(this).parent().parent('.extract_row').children('.longitude_value').text();
      var lat = $(this).parent().parent('.extract_row').children('.latitude_value').text();
      var piece = $(this).parent().parent('.extract_row').children('.piece_value').text();
      var params = '';
      var checck = $('#include_values').serialize();
      $('#verbatim_latitude').val(lat);
      $('#verbatim_longitude').val(long);
      $('#dd_latitude').val('');
      $('#dd_longitude').val('');
      params += 'piece=' + encodeURI(piece) /* piece.replace(/ /g, '%20') */;
      params += '&lat=' + encodeURI(lat) /* lat.replace(/ /g, '%20') */;
      params += '&long=' + encodeURI(long) /* long.replace(/ /g, '%20') */;
      params += '&collecting_event_id=' + $('#collecting_event_id').val();
      if (checck.length) {
        params += '&' + checck;
      }
      $.get('similar_labels', params, function (local_data) {
        $("#match_count").text(local_data.count);
        $("#matching_span").html(local_data.table);
        $("#matched_latitude").val(lat);
        $("#matched_longitude").val(long);
        $("#match_gen_georeference").val($("#generate_georeference").serialize());
        TW.views.tasks.collecting_events.parse.bind_similar_buttons();
      });
    });
  }
  
});

$(document).ready(function () {
  if ($("#ce_parse_lat_long").length) {
    //  var _init_lat_long_parse = TW.views.tasks.collecting_events.parse;
    // _init_lat_long_parse.init();
    TW.views.tasks.collecting_events.parse.init();
  }
});
