/*

   Used to select, or create a new OTU, inline.
   
*/
OTU_PICKER_WIDGET = {

  current_otu_id: null,
  current_otu_label: null,

  initialize_otu_picker: function(form, otu_type) {
    OTU_PICKER_WIDGET.initialize_autocomplete(form);
    OTU_PICKER_WIDGET.bind_new_otu_link(form);
    OTU_PICKER_WIDGET.bind_add_ok(form);
    OTU_PICKER_WIDGET.bind_undo_new_otu(form);

    OTU_PICKER_WIDGET.cache_existing_otu(form);
  },
<D-c>
  initialize_autocomplete: function(form) {
    var autocomplete_input = form.find(".otu_picker_autocomplete");

    autocomplete_input.autocomplete({
      source: '/otus/autocomplete',
      select: function (event, ui) {    
        OTU_PICKER_WIDGET.select_otu(form, ui.item.id);
        $(this).val(ui.item.label);
        return false;
      },
      response: function(event, ui) {
        if (ui.content.length === 0) {
          $("#otu_picker_add_new").removeAttr('hidden'); 
          $("#XXX_otu_name_field").val( $('#XXX_otu_picker_autocomplete').val() ); 
        }
      }

    }).autocomplete("instance")._renderItem = function (ul, item) {
      return $("<li class='autocomplete'>")
        .append("<a>" + item.label + '</a>' )
        .appendTo(ul);
    };
  },

  // user picks a new OTU
  select_otu: function(form, otu_id) {

    $("#selected_otu_id").remove();
    $('<input hidden>').attr({
      id: "selected_otu_id",
      value: otu_id,
      name: form.data('selected-otu-id-field')
    }).appendTo(form);
    OTU_PICKER_WIDGET.cache_existing_otu(form);
  },

  // user wants to create new OTU
  bind_new_otu_link: function(form) {
    form.find("#otu_picker_add_new").click(function () {
      $('#new_otu').removeAttr('hidden'); 
      $("#otu_picker_add_new").attr('hidden', true); 
      $("#XXX_otu_picker_autocomplete").attr('hidden', true); 
    })
  },

  bind_add_ok: function(form) {
    form.find("#otu_picker_add_ok").click(function () {
      OTU_PICKER_WIDGET.undo_new_otu(form);

      $("#XXX_otu_picker_autocomplete").val(OTU_PICKER_WIDGET.get_autocomplete_name(form));
    })
  },

  bind_undo_new_otu: function(form) {
    form.find("#otu_picker_new_undo").click(function () {
      OTU_PICKER_WIDGET.show_original_search(form);

      $("#XXX_otu_picker_autocomplete").val( OTU_PICKER_WIDGET.current_otu_label);
      OTU_PICKER_WIDGET.select_otu(form, OTU_PICKER_WIDGET.current_otu_id);

      $("XXX_otu_name_field").val("");
      $("#taxon_name_id_for_inline_otu_picker").val("");
      $("#taxon_name_id_for_inline_otu_picker_hidden_value").remove();
    })
  },

  show_original_search: function(form) {
    $('#new_otu').attr('hidden', true); 
    $("#XXX_otu_picker_autocomplete").removeAttr('hidden');
  },

  cache_existing_otu: function(form) {
    alert($("#selected_otu_id"));
    alert($("#XXX_otu_picker_autocomplete"));

    OTU_PICKER_WIDGET.current_otu_id = $("#selected_otu_id").val();
    OTU_PICKER_WIDGET.current_otu_label = $("#XXX_otu_picker_autocomplete").val(); 
  },

  get_autocomplete_name: function(form) {
    var s = form.find("#XXX_otu_name_field").val() + ' [' + form.find("#taxon_name_id_for_inline_otu_picker").val() + '] (a new OTU)';
    return s
  }
}; // end widget 


var _initialize_otu_picker_widget;

_initialize_otu_picker_widget = function
  init_otu_picker() {
    $('.otu_picker').each( function() {
      OTU_PICKER_WIDGET.initialize_otu_picker($(this)); 
    });
};

$(document).ready(_initialize_otu_picker_widget);

