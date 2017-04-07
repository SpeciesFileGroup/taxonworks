var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.collecting_events = TW.views.tasks.collecting_events || {};
TW.views.tasks.collecting_events.parse = TW.views.tasks.collecting_events.parse || {};
TW.views.tasks.collecting_events.parse.dates = TW.views.tasks.collecting_events.parse.dates || {};

Object.assign(TW.views.tasks.collecting_events.parse.dates, {

  init: function () {
    // var whereIgo = '/tasks/collecting_events/parse/stepwise/lat_long/';
    var whereIgo = location.pathname.replace('index', '');

    var start_next = 0;
    TW.views.tasks.collecting_events.parse.dates.bind_radio_buttons();

    $('#dates_convert').click(function (event) {
        // $("#select_area").mx_spinner('show');
        $.get('convert', $("#dates_convert_form").serialize(), function (local_data) {
            var popcorn = local_data;
            // $("#select_area").mx_spinner('hide');
          }, 'json'  // I expect a json response
        );
        event.preventDefault();
      }
    );

    $('#re_eval').click(function (event) {
      event.preventDefault();
      location.href = whereIgo + 'index?' + $('#dates_convert_form').serialize();
    });

    $('#skip').click(function (event) {
      event.preventDefault();
      location.href = whereIgo + 'skip?' + $('#dates_convert_form').serialize();
    });


    $('#save_selected').click(function (event) {
      event.preventDefault();
      location.href = whereIgo + 'save_selected?' + $('#dates_convert_form').serialize();
    });
    //  $('#lat_long_update_record').click(function (event) {
    // put the this id into the form before serializatiun
    // $('#collecting_event_id').val($('this_collecting_event').text());
    //   $.post('update', $("#lat_long_convert_form").serialize() + "&" + $("#gen_georef_box").serialize());
    //  })
  },

  bind_sequence_buttons: function () {    // for identical match buttons section
    var sel_all = $('#select_all');
    var des_all = $('#deselect_all');
    var sav_sel = $('#save_selected');
    var selectable = $('.selectable_select'); // al array for output table

    sel_all.removeAttr('disabled');
    sel_all.click(function (event) {
      // find all the checkboxes in the 'matching_span' and set them to 'checked'
      // class is selectable_select
      for (var i = 0; i < selectable.length; i++) {
        selectable[i].setAttribute('checked', true)
      }
      event.preventDefault();
    });
    des_all.removeAttr('disabled');
    des_all.click(function (event) {
      // find all the checkboxes in the 'matching_span' and set them to 'checked'
      // class is selectable_select
      for (var i = 0; i < selectable.length; i++) {
        selectable[i].removeAttribute('checked')
      }
      event.preventDefault();
    });
    sav_sel.removeAttr('disabled');
    sav_sel.click(function (event) {
      // don't know exactly what we need to do here
    });
  },

  bind_radio_buttons: function () {     // for regex match table
    $('.select_dates').click(function () {
      // selector not working
      var start_date = $(this).parent().parent('.extract_row').children('.start_date_value').text();
      var end_date = $(this).parent().parent('.extract_row').children('.end_date_value').text();
      var piece = $(this).parent().parent('.extract_row').children('.piece_value').text();
      var params = '';
      var checck = $('#include_values').serialize();
      $('#start_date').val(start_date);
      $('#verbatim_date').val(piece);
      $('#end_date').val(end_date);
      params += 'piece=' + encodeURI(piece) /* piece.replace(/ /g, '%20') */;
      params += '&start_date=' + encodeURI(start_date) /* lat.replace(/ /g, '%20') */;
      params += '&end_date=' + encodeURI(end_date) /* long.replace(/ /g, '%20') */;
      params += '&collecting_event_id=' + $('#collecting_event_id').val();
      if (checck.length) {
        params += '&' + checck;
      }
      $.get('similar_labels', params, function (local_data) {
        $("#match_count").text(local_data.count);
        $("#matching_span").html(local_data.table);
        $("#matched_start_date").val(start_date);
        $("#matched_end_date").val(end_date);
        TW.views.tasks.collecting_events.parse.dates.bind_sequence_buttons();
      });
    });
  }

});

$(document).ready(function () {
  if ($("#ce_parse_dates").length) {
    //  var _init_lat_long_parse = TW.views.tasks.collecting_events.parse;
    // _init_lat_long_parse.init();
    TW.views.tasks.collecting_events.parse.dates.init();
  }
});
