
OTU_PICKER_WIDGET = {
  initialize_otu_picker: function(form, otu_type) {
    OTU_PICKER_WIDGET.initialize_autocomplete(form);
    OTU_PICKER_WIDGET.bind_add_new(form);
    OTU_PICKER_WIDGET.bind_add_ok(form);
  },

  initialize_autocomplete: function(form) {
    var autocomplete_input = form.find(".otu_picker_autocomplete");

    autocomplete_input.autocomplete({
      source: '/otus/autocomplete',
      open: function () { // (event, ui)
        // bind_hover(form);
      },
      select: function (event, ui) {    // execute on select event in search text box
        OTU_PICKER_WIDGET.bind_existing_otu(form, ui.item.id, ui.item.label);
        return false;
      },
      response: function(event, ui) {
        
        // ui.content is the array that's about to be sent to the response callback.
        if (ui.content.length === 0) {
          $("#otu_picker_add_new").removeAttr('hidden'); // , false); // text("No results found.");
          $("#XXX_otu_name_field").val( $('#XXX_otu_picker_autocomplete').val() ); 
          
        } else {
         //  $("#loan_item_not_found").empty();
        }
      }

    }).autocomplete("instance")._renderItem = function (ul, item) {
      return $("<li class='autocomplete'>")
        .append("<a>" + item.label + ' <span class="hoverme" data-otu-id="' + item.object_id + '">...</span></a>')
        .appendTo(ul);
    };
  },

  bind_existing_otu: function(form, otu_id, label) {
    $('<input hidden>').attr({
      value: otu_id,
      name: form.data('name-field')
    }).appendTo(form);
  },

  bind_add_new: function(form) {
    form.find("#otu_picker_add_new").click(function () {
      $('#new_otu').removeAttr('hidden'); 
      $("#otu_picker_add_new").attr('hidden', true); 
      $("#XXX_otu_picker_autocomplete").attr('hidden', true); 
    })
  },

  bind_add_ok: function(form) {
    form.find("#otu_picker_add_ok").click(function () {
      $('#new_otu').attr('hidden', true); 
      $("#XXX_otu_picker_autocomplete").removeAttr('hidden');
      $("#XXX_otu_picker_autocomplete").val(OTU_PICKER_WIDGET.get_autocomplete_name(form)); //attr('hidden', true); 
    })
  },

  get_autocomplete_name: function(form) {
    form.find("input:first").val() + ' [' + form.find("input:lt(2)").val() + ']'
  }


}; // end widget 


var _initialize_otu_picker_widget;

_initialize_otu_picker_widget = function
  init_otu_picker() {
    $('.otu_picker').each( function() {
      OTU_PICKER_WIDGET.initialize_otu_picker($(this)); 
    });
};

// Initialize the script on page load
$(document).ready(_initialize_otu_picker_widget);

// This event is added by jquery.turbolinks automatically!? - see https://github.com/rails/turbolinks#jqueryturbolinks
