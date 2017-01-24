var TW = TW || {};                      // TW "namespacing" object
TW.views = TW.views || {};            // mimic directory structure in app/assets/javascripts
TW.views.tags = TW.views.tags || {};
TW.views.tags.tag_picker = TW.views.tags.tag_picker || {};

Object.assign(TW.views.tags.tag_picker, {

//
// Initialize the widget
//
  initialize_tag_picker: function (form, tag_type) {
    // turn the input into an jQuery autocompleter
    // https://jqueryui.com/autocomplete/
    //
    // all of these should likely be renamed for namespacing purposes
    this.initialize_autocomplete(form);
    //bind_new_link(form);
    //bind_switch_link(form);
    //bind_expand_link(form);
    //bind_label_mirroring(form);
    this.bind_remove_section_links(form.find('.remove_tag'));

    this.make_tag_list_sortable(form);
    this.bind_position_handling_to_submit_button(form);
  },

// Empties search text box and hide new_person div
  clear_tag_picker: function (form) {
    var tag_picker;
    tag_picker = form.find('.tag_picker_autocomplete');
    $(tag_picker).val("");
    form.find(".new_tag").attr("hidden", true);
  },

  initialize_autocomplete: function (form) {
    var autocomplete_input = form.find(".tag_picker_autocomplete");

    autocomplete_input.autocomplete({
      source: '/tags/lookup_tag',
      open: function (event, ui) {
        TW.views.tags.tag_picker.bind_hover(form);
      },
      select: function (event, ui) {    // execute on select event in search text box
        TW.views.tags.tag_picker.insert_existing_tag(form, ui.item.object_id, ui.item.label);
        TW.views.tags.tag_picker.clear_tag_picker(form);
        TW.views.tags.tag_picker.make_tag_list_sortable(form);     // was this inadvertantly lost?
        return false;
      }
    }).autocomplete("instance")._renderItem = function (ul, item) {
      return $("<li class='tag'>")
        .append("<a>" + item.label + ' <span class="hoverme" data-tag-id="' + item.object_id + '">...</span></a>')
        .appendTo(ul);
    };
  },

  make_tag_list_sortable: function (form) {
    var list_items = form.find(".tag_list");
    list_items.sortable({
      change: function (event, ui) {
        if ($('form[id^="new_"]').length == 0) {
          warn_for_save(form.find(".tag_picker_message"));
        }
      }
    });
    list_items.disableSelection();
  },

// bind a hover event to an ellipsis
  bind_hover: function (form) {
    var hiConfig = {
      sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
      interval: 400, // number = milliseconds for onMouseOver polling interval
      timeout: 200, // number = milliseconds delay before onMouseOut
      over: function () {
        var this_tag_hover;
        this_tag_hover = $(this);
        var url = ('/tags/get_definition/' + this_tag_hover.data('tagId'));
        $.get(url, function (data) {
          this_tag_hover.html('... ' + data.definition);
        });
      }, // function = onMouseOver callback (REQUIRED)
      out: function () {
        this.textContent = '...';   // how weird is this this?
      } // function = onMouseOut callback (REQUIRED)
    };
    $('.hoverme').hoverIntent(hiConfig);
  },

  bind_position_handling_to_submit_button: function (form) {
    var base_class = form.data('base-class');

    form.closest("form").find('input[name="commit"]').click(function () {
      var i = 1;
      var tag_index;
      form.find('.tag_item').each(function () {
        console.log($(this));
        tag_index = $(this).data('tag-index');
        $(this).append(
          $('<input hidden name="' + base_class + '[standard_sections_attributes][' + tag_index + '][position]" value="' + i + '" >')
        );
        i = i + 1;
      });
    });
  },

  insert_existing_tag: function (form, tag_id, label) {
    var base_class = form.data('base-class');
    var random_index = new Date().getTime();
    var tag_list = form.find(".tag_list");

    // type

    tag_list.append($('<input hidden name="' + base_class + '[standard_sections_attributes][' + random_index + '][type]" value="OtuPageLayoutSection::StandardSection">'));
    tag_list.append($('<input hidden name="' + base_class + '[standard_sections_attributes][' + random_index + '][tag_id]" value="' + tag_id + '" >'));

    // insert visible list item
    tag_list.append($('<li class="tag_item" data-tag-index="' + random_index + '">').append(label).append('&nbsp;').append(remove_tag_link()));
  },

  remove_link: function () {
    var link = $('<a href="#" class="remove_tag">remove</a>');
    TW.views.tags.tag_picker.bind_remove_section_links(link);
    return link;
  },

  bind_remove_section_links: function (links) {
    links.click(function () {
      var list_item = $(this).parent('li');
      var tag_picker = list_item.closest('.tag_picker');
      var tag_id = list_item.data('tag-id');
      var tag_index = list_item.data('tag-index');
      var base_class = tag_picker.data('base-class');

      if (tag_id != undefined) {
        var tag_list = list_item.closest('.tag_list');

        // if this is not a new tag
        // if (list_item.data('new-person') != "true")  {
        // if there is an ID from an existing item add the necessary (hidden) _destroy input
        tag_list.append($('<input hidden name="' + base_class + '[standard_sections_attributes][' + tag_index + '][id]" value="' + tag_id + '" >'));
        tag_list.append($('<input hidden name="' + base_class + '[standard_sections_attributes][' + tag_index + '][_destroy]" value="1" >'));

        // Provide a warning that the list must be saved to properly delete the records, tweak if we think necessary
        TW.views.tags.tag_picker.warn_for_save(tag_list.siblings('.tag_picker_message'));
        // }
      }
      list_item.remove();
    });
  },

  warn_for_save: function (msg_div) {
    msg_div.addClass('warning');
    msg_div.html('Update tags click required to confirm removal/reorder of tag item.');
  }

});

var _initialize_tag_picker_widget;

_initialize_tag_picker_widget = function
  init_tag_picker() {
  $('.tag_picker').each(function () {
    TW.views.tags.tag_picker.initialize_tag_picker($(this));
  });
};

// Initialize the script on page load
$(document).ready(_initialize_tag_picker_widget);

