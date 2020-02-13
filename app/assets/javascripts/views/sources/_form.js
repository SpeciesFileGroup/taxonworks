// sources.js
var TW = TW || {};
TW.view = TW.view || {};
TW.view.sources = TW.view.sources || {};

Object.assign(TW.view.sources, {
  init: function () {
    var nodeChecked;
    var that = this;

    document.querySelectorAll('input[name=source\\[type\\]]').forEach(node => {
      if (node.checked) {
        nodeChecked = node;
      }
    })

    if (nodeChecked) {
      TW.view.sources.toggle_source_form_fields(nodeChecked.value);
    }

    if ($('#source_edit_type').length > 0) {
      var currentType = $('#source_edit_type input[checked="checked"]').first();

      if ($('form[id="new_source"]').length == 1) { // current_type.val() == undefined
        // new record
        this.toggle_source_form_fields('Source::Bibtex');
        $('#source_type_sourcebibtex').attr('checked', true);
      }
      else {
        // existing record
        this.toggle_source_form_fields(currentType.val());
        // disable any option, you can't swap types
        $('#source_edit_type :input').each(function(i) {
          $(this).attr("disabled", "true");
        });
      }
    }
    $("[id^=source_type_source]").on("click", function (event) {
      that.toggle_source_form_fields(this.value);
    });
  },

  toggle_source_form_fields: function (type_label) {
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

    // TODO: revisit
    // misc form cleanup (for ajax/selects)
    if (to_show != 'bibtex') {
      $('#source_bibtex_type').val("")
      $('[name=source\\[serial_id\\]]').val("")
      $('[name=source\\[language_id\\]]').val("")
    }

  }
});

document.addEventListener('turbolinks:load', (event) => {
  TW.view.sources.init();
});
