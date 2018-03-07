/*
 Used to select, or create a new OTU, inline.
 */
OTU_PICKER_WIDGET = {

  current_otu_id: null,
  current_otu_label: null,
  object_name: null,

  initialize_otu_picker: function (form) {
    OTU_PICKER_WIDGET.object_name = form.data('object-name');
    OTU_PICKER_WIDGET.initialize_autocomplete(form);
    OTU_PICKER_WIDGET.bind_new_otu_link(form);
    OTU_PICKER_WIDGET.bind_add_ok(form);
    OTU_PICKER_WIDGET.bind_undo_new_otu(form);
    OTU_PICKER_WIDGET.cache_existing_otu(form);
  },

  initialize_autocomplete: function (form) {
    var autocomplete_input = form.find(".otu_picker_autocomplete");

    autocomplete_input.autocomplete({
      source: '/otus/autocomplete',
      select: function (event, ui) {
        OTU_PICKER_WIDGET.select_otu(form, ui.item.id);
        $(this).val(ui.item.label);
        return false;
      },
      response: function (event, ui) {
        if (ui.content.length === 0) {
          $("#otu_picker_add_new").fadeIn(250);
          $("#XXX_otu_name_field").val($('#XXX_otu_picker_autocomplete').val());
        }
      }

    }).autocomplete("instance")._renderItem = function (ul, item) {
      return $("<li class='autocomplete' id='ui-otu-id-"+ item.id + "' >")
          .append("<a>" + item.label + '</a>')
          .appendTo(ul);
    };
  },

  // user picks a new OTU
  select_otu: function (form, otu_id) {
    $("#selected_otu_id").val(otu_id);
    OTU_PICKER_WIDGET.cache_existing_otu(form);
  },

  // user wants to create new OTU
  bind_new_otu_link: function (form) {
    form.find("#otu_picker_add_new").click(function () {
      $('#new_otu').fadeIn(250);
      $("#otu_picker_add_new").hide();
      $("#XXX_otu_picker_autocomplete").attr('hidden', true);
    })
  },

  bind_add_ok: function (form) {
    form.find("#otu_picker_add_ok").click(function () {
      OTU_PICKER_WIDGET.show_original_search(form);
      $("#XXX_otu_picker_autocomplete").val(OTU_PICKER_WIDGET.get_autocomplete_name(form));

      // remove reference to previously selected otu 
      $("#selected_otu_id").val('');
    })
  },

  bind_undo_new_otu: function (form) {
    form.find("#otu_picker_new_undo").click(function () {

      $("#XXX_otu_name_field").val('');
      $("#taxon_name_id_for_inline_otu_picker").val('');

      $("input[name='" + OTU_PICKER_WIDGET.object_name + "[otu_attributes][taxon_name_id]']").remove();



      OTU_PICKER_WIDGET.show_original_search(form);

      $("#XXX_otu_picker_autocomplete").val(OTU_PICKER_WIDGET.current_otu_label);
      OTU_PICKER_WIDGET.select_otu(form, OTU_PICKER_WIDGET.current_otu_id);
    })
  },

  show_original_search: function (form) {
    form.find('#new_otu').hide(250);
    form.find("#XXX_otu_picker_autocomplete").removeAttr('hidden');
  },

  cache_existing_otu: function (form) {
    OTU_PICKER_WIDGET.current_otu_id = form.find("#selected_otu_id").val();
    OTU_PICKER_WIDGET.current_otu_label = form.find("#XXX_otu_picker_autocomplete").val();
  },

  get_autocomplete_name: function (form) {
    return (form.find("#XXX_otu_name_field").val() + ' [' + form.find("#taxon_name_id_for_inline_otu_picker").val() + '] (a new OTU)');
  }
}; // end widget 


$(document).on("turbolinks:load", function() {
  $('.otu_picker').each(function () {
    OTU_PICKER_WIDGET.initialize_otu_picker($(this));
  });
});

