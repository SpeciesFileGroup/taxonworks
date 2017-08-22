// forms.js
// A temporary place to include form-related javascripts
var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.forms = TW.workbench.forms || {};

Object.assign(TW.workbench.forms, {
  init: function() {
    $("form input.required_for_submit").change( function() {
      empty = false;
      $("form input.required_for_submit").each( function() {
        empty = ($(this).val().length <= 0);
        if (empty)
          $("#submit_with_required").attr( "disabled", "disabled");
        else
          $("#submit_with_required").removeAttr("disabled");
      });
    });
  }
});

$(document).on('turbolinks:load', function() {
  TW.workbench.forms.init();
});
