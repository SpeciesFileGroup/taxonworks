var TW = TW || {};
TW.views = TW.views || {};
TW.views.filter = TW.views.filter || {};
TW.views.filter.area_picker = TW.views.filter.area_picker || {};

Object.assign(TW.views.filter.area_picker, {

  initialize_area_picker: function (form, area_type) {
    this.initialize_autocomplete(form);
    this.bind_remove_links(form.find('.remove_area'));
  },

  // Empties search text box and hide new_person div
  clear_area_picker: function (form) {
    var area_picker;
    area_picker = form.find('.area_picker_autocomplete');
    $(area_picker).val("");
  },

  initialize_autocomplete: function (form) {
    var autocomplete_input = form.find(".area_picker_autocomplete");
    var param_name = autocomplete_input.data('paramName');

    autocomplete_input.autocomplete({
      source: '/geographic_areas/autocomplete',
      appendTo: autocomplete_input.parent(),
      open: function (event, ui) {
        TW.views.filter.area_picker.bind_hover(form);
      },
      select: function (event, ui) {    // execute on select event in search text box
        TW.views.filter.area_picker.insert_existing_area(form, ui.item.id, ui.item.label_html, param_name);
        TW.views.filter.area_picker.clear_area_picker(form);
        return false;
      }

    }).autocomplete("instance")._renderItem = function (ul, item) {
      return $("<li class='area'>")
        .append("<a data-geographic-area-id= '" + item.id + "'>" + item.label_html + '<span>...</span></a>')
        .appendTo(ul);
    };
  },

  // bind a hover event to an ellipsis
  bind_hover: function (form) {
    var hiConfig = {
      sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
      interval: 400,  // number = milliseconds for onMouseOver polling interval
      timeout: 200,   // number = milliseconds delay before onMouseOut
      over: function () {
        var this_area_hover;
        this_area_hover = $(this);   // modified to not do AJAX call, but use attribute already extant
        this_area_hover.html('... ' + this_area_hover.data('area-label_html'));
      }, // function = onMouseOver callback (REQUIRED)
      out: function () {
        this.textContent = '...'; 
      } // function = onMouseOut callback (REQUIRED)
    };
    $('.hoverme').hoverIntent(hiConfig);
  },

  insert_existing_area: function (form, area_id, label, param_name) {
    var base_class = 'area_object',
        random_index = new Date().getTime(),
        area_list = form.find(".area_list"),
        label_text = document.createElement("div");
        label_text.innerHTML = label;
        
    // insert visible list item
        jQuery(label_text).children("span").remove(); // Remove has shape
        area_list.append($('<li class="area_item" data-area-index="' + random_index + '">')
          .append(TW.views.filter.area_picker.remove_link())
          .append(jQuery(label_text).text())          
          .append($('<input hidden name="' + param_name + '[]" value="' + area_id + '" >'))
        );
  },

  //
  // Binding actions (clicks) to links
  //
  remove_link: function () {
    var link = $('<a href="#" data-turbolinks="false" class="remove_area" data-icon="trash"></a>');
    TW.views.filter.area_picker.bind_remove_links(link);
    return link;
  },

  bind_remove_links: function (links) {
    links.click(function () {
      var list_item = $(this).parent('li');
      var area_picker = list_item.closest('.area_picker');
      var area_id = list_item.data('area-id');
      var area_index = list_item.data('area-index');
      var base_class = 'area_object';

      if (area_id != undefined) {
        var area_list = list_item.closest('.area_list');

        area_list.append($('<input hidden name="' + base_class + '[areas_attributes][' + area_index + '][geographic_area_id]" value="' + area_id + '" >'));
        area_list.append($('<input hidden name="' + base_class + '[areas_attributes][' + area_index + '][_destroy]" value="1" >'));

        // Provide a warning that the list must be saved to properly delete the records, tweak if we think necessary
        TW.views.filter.area_picker.warn_for_save(area_list.siblings('.area_picker_message'));
      }
      list_item.remove();
    });
  },

  warn_for_save: function (msg_div) {
    msg_div.addClass('warning');
    msg_div.html('Update areas click required to confirm removal/reorder of area item.');
  }

});

var _initialize_area_picker_widget;

_initialize_area_picker_widget = function
  init_area_picker() {
  $('.area_picker').each(function () {
    TW.views.filter.area_picker.initialize_area_picker($(this));
  });
};

$(document).on("turbolinks:load", _initialize_area_picker_widget);

