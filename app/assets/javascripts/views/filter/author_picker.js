var TW = TW || {};
TW.views = TW.views || {};
TW.views.filter = TW.views.filter || {};
TW.views.filter.author_picker = TW.views.filter.author_picker || {};

Object.assign(TW.views.filter.author_picker, {

  initialize_author_picker: function (form, author_type) {
    this.initialize_autocomplete(form);
    this.bind_remove_links(form.find('.remove_author'));
  },

  // Empties search text box and hide new_person div
  clear_author_picker: function (form) {
    var author_picker;
    author_picker = form.find('.author_picker_autocomplete');
    $(author_picker).val("");
  },

  initialize_autocomplete: function (form) {
    var autocomplete_input = form.find(".author_picker_autocomplete");
    var param_name = autocomplete_input.data('paramName');

    autocomplete_input.autocomplete({
      source: '/people/taxon_name_author_autocomplete',
      appendTo: autocomplete_input.parent(),
      open: function (event, ui) {
        TW.views.filter.author_picker.bind_hover(form);
      },
      select: function (event, ui) {    // execute on select event in search text box
        TW.views.filter.author_picker.insert_existing_author(form, ui.item.id, ui.item.label_html, param_name);
        TW.views.filter.author_picker.clear_author_picker(form);
        return false;
      }

    }).autocomplete("instance")._renderItem = function (ul, item) {
      return $("<li class='author'>")
        .append("<a data-author-id= '" + item.id + "'>" + item.label_html + '<span>...</span></a>')
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
        var this_author_hover;
        this_author_hover = $(this);   // modified to not do AJAX call, but use attribute already extant
        this_author_hover.html('... ' + this_author_hover.data('author-label_html'));
      }, // function = onMouseOver callback (REQUIRED)
      out: function () {
        this.textContent = '...';
      } // function = onMouseOut callback (REQUIRED)
    };
    $('.hoverme').hoverIntent(hiConfig);
  },

  insert_existing_author: function (form, author_id, label, param_name) {
    var base_class = 'author_object',
      random_index = new Date().getTime(),
      author_list = form.find(".author_list"),
      label_text = document.createElement("div");
    label_text.innerHTML = label;

    // insert visible list item
    jQuery(label_text).children("span").remove(); // Remove has shape
    author_list.append($('<li class="author_item" data-author-index="' + random_index + '">')
      .append(TW.views.filter.author_picker.remove_link())
      .append(jQuery(label_text).text())
      .append($('<input hidden name="' + param_name + '[]" value="' + author_id + '" >'))
    );
  },

  //
  // Binding actions (clicks) to links
  //
  remove_link: function () {
    var link = $('<a href="#" data-turbolinks="false" class="remove_author" data-icon="trash"></a>');
    TW.views.filter.author_picker.bind_remove_links(link);
    return link;
  },

  bind_remove_links: function (links) {
    links.click(function () {
      var list_item = $(this).parent('li');
      var author_picker = list_item.closest('.author_picker');
      var author_id = list_item.data('author-id');
      var author_index = list_item.data('author-index');
      var base_class = 'author_object';

      if (author_id != undefined) {
        var author_list = list_item.closest('.author_list');

        author_list.append($('<input hidden name="' + base_class + '[authors_attributes][' + author_index + '][author_id]" value="' + author_id + '" >'));
        author_list.append($('<input hidden name="' + base_class + '[authors_attributes][' + author_index + '][_destroy]" value="1" >'));

        // Provide a warning that the list must be saved to properly delete the records, tweak if we think necessary
        TW.views.filter.author_picker.warn_for_save(author_list.siblings('.author_picker_message'));
      }
      list_item.remove();
    });
  },

  warn_for_save: function (msg_div) {
    msg_div.addClass('warning');
    msg_div.html('Update authors click required to confirm removal/reorder of author item.');
  }

});

var _initialize_author_picker_widget;

_initialize_author_picker_widget = function
  init_author_picker() {
  $('.author_picker').each(function () {
    TW.views.filter.author_picker.initialize_author_picker($(this));
  });
};

$(document).on("turbolinks:load", _initialize_author_picker_widget);

