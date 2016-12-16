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
    this.bind_new_link(form);
    this.bind_switch_link(form);
    this.bind_expand_link(form);
    this.bind_label_mirroring(form);
    this.bind_remove_links(form.find('.remove_tag'));
    this.make_tag_list_sortable(form);
    this.bind_position_handling_to_submit_button(form);
  },

// Return a first name, splits on (white) space or comma
  get_first_name: function (string) {

  // if there is no space or , there is no first name
  if ((string.indexOf(",") > 1) || (string.indexOf(" ") > 1)) {
    var delimiter;
    if (string.indexOf(",") > 1) {
      delimiter = ","
    }
    if (string.indexOf(", ") > 1) {
      delimiter = ", "
    }
    if (string.indexOf(" ") > 1 && delimiter != ", ") {
      delimiter = " "
    }
    return string.split(delimiter, 2)[0];
  } else {
    return null;
  }
  },

// Return a last name split on (white) space or commma
  get_last_name: function (string) {
  // if there no space or comma then the whole string is the *last* name
  if ((string.indexOf(",") > 1) || (string.indexOf(" ") > 1)) {
    var delimiter;
    if (string.indexOf(",") > 1) {
      delimiter = ","
    }
    if (string.indexOf(", ") > 1) {
      delimiter = ", "
    }
    if (string.indexOf(" ") > 1 && delimiter != ", ") {
      delimiter = " "
    }
    return string.split(delimiter, 2)[1];
  } else {
    return string
  }
  },

// Build a name string - first_name and last_name must be strings
  ags_get_full_name: function t(first_name, last_name) {
  var separator = "";
  if (!!last_name && !!first_name) {
    separator = ", ";
  }
  return (last_name + separator + first_name);
  },

// Empties search text box and hide new_person div
  clear_tag_picker: function (form) {
  var tag_picker;
  tag_picker = form.find('.tag_picker_autocomplete');
  $(tag_picker).val("");
  form.find(".new_person").attr("hidden", true);
  },

  initialize_autocomplete: function (form) {
  var autocomplete_input = form.find(".tag_picker_autocomplete");

  autocomplete_input.autocomplete({
    source: '/people/lookup_person',
    open: function (event, ui) {
      TW.views.tags.tag_picker.bind_hover(form);
    },
    select: function (event, ui) {    // execute on select event in search text box
      TW.views.tags.tag_picker.insert_existing_person(form, ui.item.object_id, ui.item.label);
      TW.views.tags.tag_picker.clear_tag_picker(form);
      return false;
    }
  }).autocomplete("instance")._renderItem = function (ul, item) {
    return $("<li class='autocomplete'>")
      .append("<a>" + item.label + ' <span class="hoverme" data-person-id="' + item.object_id + '">...</span></a>')
      .appendTo(ul);
  };

  // Copy search textbox content to .new_person .name_label
  autocomplete_input.keyup(function () {
    var input_term = autocomplete_input.val();
    var last_name = get_last_name(input_term);
    var first_name = get_first_name(input_term);

    if (input_term.length == 0) {
      form.find(".new_person").attr("hidden", true);
    }
    else {
      form.find(".new_person").removeAttr("hidden");
    }

    if (input_term.indexOf(",") > 1) {   //last name, first name format
      var swap = first_name;
      first_name = last_name;
      last_name = swap;
    }

    form.find(".first_name").val(first_name).change();
    form.find(".last_name").val(last_name).change();
  });
  },

//
// Binding actions (clicks) to links
//

  bind_new_link: function (form) {
  // Add a tag to the list via the add new form
  form.find(".tag_picker_add_new").click(function () {
    this.insert_new_person(form);
    form.find('.new_person').attr("hidden", true); // hide the form fields
    this.clear_tag_picker(form); // clear autocomplete input box
  });
  },

  insert_existing_person: function (form, person_id, label) {
  var base_class = form.data('base-class');
  var random_index = new Date().getTime();
  var tag_list = form.find(".tag_list");

  // type
  tag_list.append($('<input hidden name="' + base_class + '[tags_attributes][' + random_index + '][type]" value="' + form.data('tag-type') + '" >'));
  tag_list.append($('<input hidden name="' + base_class + '[tags_attributes][' + random_index + '][person_id]" value="' + person_id + '" >'));

  // insert visible list item
  tag_list.append($('<li class="tag_item" data-tag-index="' + random_index + '">').append(label).append('&nbsp;').append(remove_link()));
  },

  insert_new_person: function (form) {
  var base_class = form.data('base-class');
  var random_index = new Date().getTime();
  var person_base = base_class + '[tags_attributes][' + random_index + '][person_attributes]';
  var tag_list = form.find(".tag_list");

  // type
  tag_list.append($('<li class="tag_item" data-new-person="true" data-tag-index="' + random_index + '" >')
    .append(form.find('.name_label').text() + '&nbsp;')
    .append($('<input hidden name="' + base_class + '[tags_attributes][' + random_index + '][type]" value="' + form.data('tag-type') + '" >'))

    // names
    .append($('<input hidden name="' + person_base + '[last_name]" value="' + form.find(".last_name").val() + '" >'))
    .append($('<input hidden name="' + person_base + '[first_name]" value="' + form.find(".first_name").val() + '" >'))
    .append($('<input hidden name="' + person_base + '[suffix]" value="' + form.find(".suffix").val() + '" >'))
    .append($('<input hidden name="' + person_base + '[prefix]" value="' + form.find(".prefix").val() + '" >'))
    .append(this.remove_link())
  );
  },

  remove_link: function () {
  var link = $('<a href="#" class="remove_tag">remove</a>');
    this.bind_remove_links(link);
  return link;
  },

  bind_switch_link: function (form) {
  // click switches the values in the first & last names
  form.find(".tag_picker_switch").click(function () {
    var tmp = form.find(".first_name").val();
    form.find(".first_name").val(form.find(".last_name").val()).change();
    form.find(".last_name").val(tmp).change();
  });
  },

  bind_expand_link: function (form) {
  // click alternately hides and displays tag_picker_person_form
  form.find(".tag_picker_expand").click(function () {
    form.find(".tag_picker_person_form").toggle();
  });
  },

  bind_label_mirroring: function (form) {
  // update mirrored label
  form.find(".tag_picker_person_form input").on("change keyup", function () {
    form.find(".name_label").html(
      get_full_name(form.find(".first_name").val(), form.find(".last_name").val())
    );
  });
  },

// bind a hover event to an ellipsis
  bind_hover: function (form) {
  var hiConfig = {
    sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
    interval: 400, // number = milliseconds for onMouseOver polling interval
    timeout: 200, // number = milliseconds delay before onMouseOut
    over: function () {
      var url = ('/people/' + $(this).data('personId') + '/details');
      $.get(url, function (data) {
        form.find(".person_details").html(data);
      });
    }, // function = onMouseOver callback (REQUIRED)
    out: function () {
      form.find(".person_details").html('');
    } // function = onMouseOut callback (REQUIRED)
  };
  $('.hoverme').hoverIntent(hiConfig);
  },

// Bind the remove action/functionality to a links
  bind_remove_links: function (links) {
  links.click(function () {
    list_item = $(this).parent('li');
    var tag_picker = list_item.closest('.tag_picker');
    var tag_id = list_item.data('tag-id');
    var tag_index = list_item.data('tag-index');
    var base_class = tag_picker.data('base-class');

    if (tag_id != undefined) {
      var tag_list = list_item.closest('.tag_list');

      // if this is not a new person
      if (list_item.data('new-person') != "true") {
        // if there is an ID from an existing item add the necessary (hidden) _destroy input
        tag_list.append($('<input hidden name="' + base_class + '[tags_attributes][' + tag_index + '][id]" value="' + tag_id + '" >'));
        tag_list.append($('<input hidden name="' + base_class + '[tags_attributes][' + tag_index + '][_destroy]" value="1" >'));

        // Provide a warning that the list must be saved to properly delete the records, tweak if we think necessary
        warn_for_save(tag_list.siblings('.tag_picker_message'));
      }
    }
    list_item.remove();
  });
  },

// function warn_for_save(msg_div) {
//   msg_div.addClass('warning');
//   msg_div.html('Update required to confirm removal/reorder.');
// }

  make_tag_list_sortable: function (form) {
  var list_items = form.find('.tag_list');
  list_items.sortable({
    change: function (event, ui) {
      if ($('form[id^="new_"]').length == 0) {
        this.warn_for_save(form.find('.tag_picker_message'));
      }
    }
  });
  list_items.disableSelection();
  },

  bind_position_handling_to_submit_button: function (form) {
  var base_class = form.data('base-class');

  form.closest('form').find('input[name="commit"]').click(function () {
    var i = 1;
    var tag_index;
    form.find('.tag_item').each(function () {
      console.log($(this));
      tag_index = $(this).data('tag-index');
      $(this).append(
        $('<input hidden name="' + base_class + '[tags_attributes][' + tag_index + '][position]" value="' + i + '" >')
      );
      i = i + 1;
    });
  });
}

});

var _initialize_tag_picker_widget;

_initialize_tag_picker_widget = function init_tag_picker() {
  $('.tag_picker').each(function () {
    var tag_type = $(this).data('tag-type');
    TW.views.tags.tag_picker.initialize_tag_picker($(this), tag_type);
  });
};

// Initialize the script on page load
$(document).ready(_initialize_tag_picker_widget);

// This event is added by jquery.turbolinks automatically!? - see https://github.com/rails/turbolinks#jqueryturbolinks
