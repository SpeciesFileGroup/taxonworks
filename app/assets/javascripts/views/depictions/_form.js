// depiction.js

function toggle_depiction_form_fields(type_label) {
  var types = ['otu', 'collecting_event', 'collection_object'];
  var to_show = type_label;

  // hide not visible (we can't hide everything
  // and show because we lose content of inputs
  types.forEach(function(element) {
    $('[id^=fields_for_'+element+']').hide();
  });

  // show everything
  $('#fields_for_' + to_show).show();
}

$(document).on('tubolinks:load', function() {
  if ($('#depiction_edit').length > 0) {
    var current_type = $('#depiction_edit input[checked="checked"]').first();

    if (current_type.val() == undefined) {
      // new record
      toggle_depiction_form_fields('collection_object');
      $('#collection_object').attr('checked', "true");
    }
    else {
      // existing record
      toggle_depiction_form_fields(current_type.val());
       // disable any option, you can't swap types
      $('#depiction_edit :input').each(function(i) {
        $(this).attr("disabled", "true");
      });
    }

    $("[id^=depiction_edit] :input").on("click", function(event) {
      toggle_depiction_form_fields(this.id);
    });
   }
 }); 

