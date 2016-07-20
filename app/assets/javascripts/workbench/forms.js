// forms.js
// A temporary place to include form-related javascripts

function bind_required_fields_and_submit() {
  $("form input.required_for_submit").change( function() {
    empty = false
    $("form input.required_for_submit").each( function() {
      empty = ($(this).val().length <= 0);
      if (empty)
        $("#submit_with_required").attr( "disabled", "disabled");
      else
        $("#submit_with_required").removeAttr("disabled");
    });
  });
}

$(document).ready(function() {
  bind_required_fields_and_submit();
});
