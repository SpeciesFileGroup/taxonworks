var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.collecting_events = TW.views.tasks.collecting_events || {};
TW.views.tasks.collecting_events.parse = TW.views.tasks.collecting_events.parse || {};
TW.views.tasks.collecting_events.parse.dates = TW.views.tasks.collecting_events.parse.dates || {};

Object.assign(TW.views.tasks.collecting_events.parse.dates, {

  init: function () {
    var whereIgo = location.pathname.replace('index', '');

    var start_next = 0;
    TW.views.tasks.collecting_events.parse.dates.bind_radio_buttons();

    $('#dates_reprocess').click(function (event) {
      // selector not working
      var start_date = $('#start_date').val();
      var end_date = $('#end_date').val();
      var piece = $('#verbatim_date').val();
      var method = $("#selected_method").attr('value');
      ;    // maybe we could pick out a viable method?
      var params = '';
      params += 'piece=' + encodeURIComponent(piece) /* piece.replace(/ /g, '%20') */;
      params += '&start_date=' + start_date;
      params += '&end_date=' + end_date;
      params += '&collecting_event_id=' + $('#collecting_event_id').val();
      params += '&method=' + method;
      var checck = $('#include_values').serialize();
      if (checck.length) {
        params += '&' + checck;
      }
      // params += $('#dates_convert_form').serialize();
      $.get('similar_labels', params, function (local_data) {
        $("#match_count").text(local_data.count);
        $("#matching_span").html(local_data.table);
        $("#matched_start_date").val(start_date);
        $("#matched_end_date").val(end_date);
        TW.views.tasks.collecting_events.parse.dates.bind_sequence_buttons();
      });
      event.preventDefault();
    });

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
        selectable[i]['checked'] = true;
      }
      event.preventDefault();
    });
    des_all.removeAttr('disabled');
    des_all.click(function (event) {
      // find all the checkboxes in the 'matching_span' and set them to 'checked'
      // class is selectable_select
      for (var i = 0; i < selectable.length; i++) {
        selectable[i]['checked'] = false;
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
      var method = $(this).parent().parent('.extract_row').children('.method_value').text();
      $("#selected_method").attr('value', method);      //
      var params = '';
      $('#start_date').val(start_date);
      $('#verbatim_date').val(piece);
      $('#end_date').val(end_date);
      params += 'piece=' + encodeURIComponent(piece) /* piece.replace(/ /g, '%20') */;
      params += '&start_date=' + start_date;
      params += '&end_date=' + end_date;
      params += '&collecting_event_id=' + $('#collecting_event_id').val();
      params += '&method=' + method;
      var checck = $('#include_values').serialize();
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

$(document).on("turbolinks:load", function () {
  if ($("#ce_parse_dates").length) {
    //  var _init_lat_long_parse = TW.views.tasks.collecting_events.parse;
    // _init_lat_long_parse.init();
    TW.views.tasks.collecting_events.parse.dates.init();
  }
});
