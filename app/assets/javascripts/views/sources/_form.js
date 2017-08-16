// sources.js


function toggle_source_form_fields(type_label) {
  var types = ['bibtex', 'verbatim', 'human'];
  var to_show = type_label.split('::')[1].toLowerCase();

  // show everything
  $('#fields_for_' + to_show).show();

  // hide not visible (we can't hide everything
  // and show because we lose content of inputs

  types.forEach( function(element) {
    if(element != to_show) {
      $('#fields_for_'+element).each(function(i) {
        $(this).hide();   
      });
      $('#fields_for_'+element+' :input').each(function(i) {
        $(this).val(null);   
      });      
    }
  });

  // misc form cleanup (for ajax/selects)
  if (to_show != 'bibtex') {
    $('#source_bibtex_type').val("")
  }
  $('[name=source\\[serial_id\\]]').val("")
}

$(document).on('turbolinks:load', function() {
  if ($('#source_edit_type').length > 0) {
    var current_type = $('#source_edit_type input[checked="checked"]').first();

    if ($('form[id="new_source"]').length == 1) { // current_type.val() == undefined
      // new record
      toggle_source_form_fields('Source::Bibtex');
      $('#source_type_sourcebibtex').attr('checked', true);
    }
    else {
      // existing record
      toggle_source_form_fields(current_type.val());
      // disable any option, you can't swap types
      $('#source_edit_type :input').each(function(i) {
        $(this).attr("disabled", "true");
      });
    }
  }
  $("[id^=source_type_source]").on("click", function (event) {
    toggle_source_form_fields(this.value);
  });
});

