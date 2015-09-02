// Empties search text box and hide new_person div
function clear_topic_picker(form) {
  var topic_picker;
  topic_picker = form.find('.topic_picker_autocomplete');
  $(topic_picker).val("");
  form.find(".new_topic").attr("hidden", true);
}

function initialize_topic_autocomplete(form) {
  var autocomplete_input = form.find(".topic_picker_autocomplete");

  autocomplete_input.autocomplete({
    source: '/topics/lookup_topic',
    open: function (event, ui) {
      bind_hover_topic(form);
    },
    select: function (event, ui) {    // execute on select event in search text box
      insert_existing_topic(form, ui.item.object_id, ui.item.label)
      clear_topic_picker(form);
      make_topic_list_sortable(form);     // was this inadvertantly lost?
      return false;
    }
  }).autocomplete("instance")._renderItem = function (ul, item) {
    return $("<li class='topic'>")
      .append("<a>" + item.label + ' <span class="hoverme" data-topic-id="' + item.object_id + '">...</span></a>')
      .appendTo(ul);
  };
};

function make_topic_list_sortable(form) {
  var list_items = form.find(".topic_list");
  list_items.sortable({
    change: function (event, ui) {
      if ($('form[id^="new_"]').length == 0) {
        warn_for_save(form.find(".topic_picker_message"));
      }
    }
  });
  list_items.disableSelection();
}
// bind a hover event to an ellipsis
function bind_hover_topic(form) {
  hiConfig = {
    sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
    interval: 400, // number = milliseconds for onMouseOver polling interval
    timeout: 200, // number = milliseconds delay before onMouseOut
    over: function () {
      //var url = ('/otu_page_layouts/' + $(this).data('topic_id') + '/details');
      //$.get(url, function( data ) {
      //  form.find(".person_details" ).html( data );
      //});
    }, // function = onMouseOver callback (REQUIRED)
    out: function () {
      //form.find(".person_details" ).html('');
    } // function = onMouseOut callback (REQUIRED)
  };
  $('.hoverme').hoverIntent(hiConfig);
}

function bind_topic_position_handling_to_submit_button(form) {
  var base_class = form.data('base-class');

  form.closest("form").find('input[name="commit"]').click(function () {
    var i = 1;
    var topic_index;
    form.find('.topic_item').each(function () {
      console.log($(this));
      topic_index = $(this).data('section-index');
      $(this).append(
        $('<input hidden name="' + base_class + '[standard_sections_attributes][' + topic_index + '][position]" value="' + i + '" >')
      );
      i = i + 1;
    });
  });
}

function insert_existing_topic(form, topic_id, label) {
  var base_class = form.data('base-class');
  var random_index = new Date().getTime();
  var topic_list = form.find(".topic_list");

  // type

  topic_list.append($('<input hidden name="' + base_class + '[standard_sections_attributes][' + random_index + '][type]" value="OtuPageLayoutSection::StandardSection">'));
  topic_list.append($('<input hidden name="' + base_class + '[standard_sections_attributes][' + random_index + '][topic_id]" value="' + topic_id + '" >'));

  // insert visible list item
  topic_list.append($('<li class="topic_item" data-section-index="' + random_index + '">').append(label).append('&nbsp;').append(remove_topic_link()));
};

function remove_topic_link() {
  var link = $('<a href="#" class="remove_topic">remove</a>');
  bind_remove_section_links(link);
  return link;
}

function bind_remove_section_links(links) {
  links.click(function () {
    list_item = $(this).parent('li');
    var topic_picker = list_item.closest('.topic_picker');
    var topic_id = list_item.data('section-id');
    var topic_index = list_item.data('section-index');
    var base_class = topic_picker.data('base-class');

    if (topic_id != undefined) {
      var topic_list = list_item.closest('.topic_list');

      // if this is not a new topic
      // if (list_item.data('new-person') != "true")  {
      // if there is an ID from an existing item add the necessary (hidden) _destroy input
      topic_list.append($('<input hidden name="' + base_class + '[standard_sections_attributes][' + topic_index + '][id]" value="' + topic_id + '" >'));
      topic_list.append($('<input hidden name="' + base_class + '[standard_sections_attributes][' + topic_index + '][_destroy]" value="1" >'));

      // Provide a warning that the list must be saved to properly delete the records, tweak if we think necessary
      warn_for_save(topic_list.siblings('.topic_picker_message'));
      // }
    }
    list_item.remove();
  });
};

//
// Initialize the widget
//
function initialize_topic_picker(form, topic_type) {
  // turn the input into an jQuery autocompleter
  // https://jqueryui.com/autocomplete/
  //
  // all of these should likely be renamed for namespacing purposes
  initialize_topic_autocomplete(form);
  //bind_new_link(form);
  //bind_switch_link(form);
  //bind_expand_link(form);
  //bind_label_mirroring(form);
  bind_remove_section_links(form.find('.remove_topic'));

  make_topic_list_sortable(form);
  bind_topic_position_handling_to_submit_button(form);
};

var _initialize_topic_picker_widget;

_initialize_topic_picker_widget = function
  init_topic_picker() {
  $('.topic_picker').each(function () {
    initialize_topic_picker($(this));
  });
};

// Initialize the script on page load
$(document).ready(_initialize_topic_picker_widget);

