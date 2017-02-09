/*
  Handles the selection and removal of confidence levels on confidences/new. 
  !! Form works per referenced object with nested attributes, not on a Confidence instance.
  Could ulitmately be simplified to reference global_ids in various places.

*/
var TW = TW || {};                    
TW.views = TW.views || {};           
TW.views.confidences = TW.views.confidences || {};
TW.views.confidences.form = TW.views.confidences.form || {};

Object.assign(TW.views.confidences.form, {

  initialize: function (form) {
    $(".confidence_level_form").each(function () {
      TW.views.confidences.form.initialize_form($(this));
    });
  },

  initialize_form: function (form) {
    this.initialize_confidence_level_picker(form);
    this.bind_remove_links(form.find('.remove_confidence'));
  },

  clear_confidence_level_picker: function (form) {
    var confidence_level_picker = form.find('.confidence_level_picker_autocomplete');
    $(confidence_level_picker).val("");
  },

  initialize_confidence_level_picker: function (form) {
    var autocomplete_input = form.find(".confidence_level_picker_autocomplete");

    autocomplete_input.autocomplete({
      source: '/confidence_levels/lookup',
      open: function (event, ui) {
        TW.views.confidences.form.bind_hover(form);
      },
      select: function (event, ui) {    
        TW.views.confidences.form.insert_confidence(form, ui.item.object_id, ui.item.label);
        TW.views.confidences.form.clear_confidence_level_picker(form);
        return false;
      }

    }).autocomplete("instance")._renderItem = function (ul, item) {
      return $("<li class='confidence'>")
        .append("<a>" + item.label + ' <span class="hoverme" data-confidence-level-definition="' + item.definition + '" + data-confidence-level-id="' + item.object_id + '">...</span></a>')
        .appendTo(ul);
    };

  },

  // bind a hover event to an ellipsis
  bind_hover: function (form) {
    var hiConfig = {
      sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
      interval: 400, // number = milliseconds for onMouseOver polling interval
      timeout: 200, // number = milliseconds delay before onMouseOut
      over: function () {
        var this_confidence_hover;
        this_confidence_hover = $(this);   // modified to not do AJAX call, but use attribute already extant
        this_confidence_hover.html('... ' + this_confidence_hover.data('confidenceLevelDefinition'));
      }, // function = onMouseOver callback (REQUIRED)
      out: function () {
        this.textContent = '...'; 
      } // function = onMouseOut callback (REQUIRED)
    };
    $('.hoverme').hoverIntent(hiConfig);
  },

  insert_confidence: function (form, confidence_level_id, label) {
    var base_class = 'confidence_object[confidences_attributes]';
    var random_index = new Date().getTime();
    var base_class = 'confidence_object[confidences_attributes][' + random_index + ']';
    var confidence_list = form.find(".confidence_list");

    confidence_list.append($('<input hidden name="' + base_class + '[confidence_level_id]" value="' + confidence_level_id + '" >'));
    confidence_list.append($('<li class="confidence_item" data-confidence-index="' + random_index + '">').append(label).append('&nbsp;').append(TW.views.confidences.form.remove_link()));
  },

  remove_link: function () {
    var link = $('<a href="#" class="remove_confidence_level">remove</a>');
    TW.views.confidences.form.bind_remove_links(link);
    return link;
  },

  bind_remove_links: function (links) {
    links.click(function () {
      var list_item = $(this).parent('li');
      var form = list_item.closest('.confidence_picker');

      var confidence_id = list_item.data('confidence-id');
      var confidence_index = list_item.data('confidence-index');

      var base_class = 'confidence_object[confidences_attributes]';

      if (confidence_id != undefined) {
        var confidence_list = list_item.closest('.confidence_list');
        confidence_list.append($('<input hidden name="' + base_class + '[' + confidence_index + '][id]" value="' + confidence_id + '" >'));
        confidence_list.append($('<input hidden name="' + base_class + '[' + confidence_index + '][_destroy]" value="1" >'));
        TW.views.confidences.form.warn_for_save(confidence_list.siblings('.confidence_level_picker_alert'));
      }
      
      list_item.remove();
    });
  },

  warn_for_save: function (msg_div) {
    msg_div.show();
    msg_div.addClass('warning');
    msg_div.html('Update confidences click required to confirm removal/reorder of confidence level.');
  }
});

$(document).ready(TW.views.confidences.form.initialize);

