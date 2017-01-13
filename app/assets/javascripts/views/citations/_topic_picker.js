function insert_existing_topic2(form, topic_id, label) {
  var base_class = 'citation'; // form.data('base-class');
  var random_index = new Date().getTime(); 
  var citation_topic_list = form.find(".citation_topic_list");

  citation_topic_list.append( $('<input hidden name="' + base_class + '[citation_topics_attributes][' +  random_index + '][topic_id]" value="' + topic_id +  '" >') );

  // insert visible list item
  citation_topic_list.append( $('<li class="citation_topic_item" data-citation-topic-index="' + random_index + '">').append(label).append('&nbsp;').append(remove_citation_topic_link()) );
};

function clear_citation_topic_picker(form) {
  var citation_topic_picker;
  citation_topic_picker = form.find('.citation_topic_autocomplete');
  $(citation_topic_picker).val("");
  form.find(".new_topic").attr("hidden", true);
}

function initialize_citation_topic_autocomplete(form) {
  var autocomplete_input = form.find(".citation_topic_autocomplete");

  autocomplete_input.autocomplete({
    source: '/topics/lookup_topic',
    open: function (event, ui) {
    },
    select: function (event, ui) {    // execute on select event in search text box
      insert_existing_topic2(form, ui.item.object_id, ui.item.label);
      clear_citation_topic_picker(form);
      return false;
    }
  }).autocomplete("instance")._renderItem = function (ul, item) {
    return $("<li class='autocomplete'>")
      .append("<a>" + item.label + '</a>')
      .appendTo(ul);
  };

  autocomplete_input.keyup(function () {
    var input_term = autocomplete_input.val();
    var name = input_term; 

    if (input_term.length == 0) {
      form.find(".new_topic").attr("hidden", true);
    }
    else {
      form.find(".new_topic").removeAttr("hidden");
    };

    form.find(".name").val(name).change();
    form.find(".definition").val("").change();
  });
};

function bind_definition_listener(form) {
    form.find(".definition").keyup(function() {
      var d = form.find(".definition").val();
      if (d.length == 0) {
        $(".citation_topic_picker_add_new").hide();
      }
      else {
        $(".citation_topic_picker_add_new").css("display","flex");
      }
    })
}

//
// Binding actions (clicks) to links 
//
function bind_new_topic_link(form) {
  // Add a citation_topic to the list via the add new form 
  form.find(".citation_topic_picker_add_new").click(function () {
    insert_new_topic(form);
    form.find('.new_topic').attr("hidden", true); 
    clear_citation_topic_picker(form); 
  });
}

function insert_new_topic(form) {
  var base_class = 'citation'; 
  var random_index = new Date().getTime(); 
  var citation_topic_base = base_class + '[citation_topics_attributes][' + random_index + ']';
  var topic_base = citation_topic_base + '[topic_attributes]'; 
  var citation_topic_list = form.find(".citation_topic_list");
  
  var name = form.find('.citation_topic_autocomplete').val();

  citation_topic_list.append(
      $('<li class="citation_topic_item" data-new-topic="true" data-topic-index="' + random_index + '" >')
      .append('<div><div>' + name + '</div><input name="' + citation_topic_base + '[pages]" placeholder="Pages"></div>')
      .append( $('<input hidden name="' + topic_base + '[name]" value="' + name + '" >') )
      .append( $('<input hidden name="' + topic_base + '[definition]" value="' + form.find(".definition").val() + '" >') )

      .append(remove_citation_topic_link())
      );

  $(".citation_topic_picker_add_new").hide();
};

function remove_citation_topic_link() {
  var link = $('<a href="#" class="remove_citation_topic delete-circle">remove</a>');
  bind_remove_citation_topic_links(link);
  return link;
}

function bind_topic_label_mirroring(form) {
  form.find(".citation_topic_picker_topic_form input").on("change keyup", function () {
    form.find(".name_label").html(
      form.find(".name").val()
    );
  });
}

// Bind the remove action/functionality to a links
function bind_remove_citation_topic_links(links) {
  links.click(function () {
    var list_item = $(this).parent('li');
    var citation_topic_picker = list_item.closest('.citation_topic_picker');
    var citation_topic_id = list_item.data('citation-topic-id');
    var citation_topic_index = list_item.data('citation-topic-index');

    var base_class = 'citation'; // citation_topic_picker.data('base-class');

    if (citation_topic_id != undefined) {
      var citation_topic_list = list_item.closest('.citation_topic_list');
     
      // if this is not a new person 
      if (list_item.data('new-topic') != "true")  {
        // if there is an ID from an existing item add the necessary (hidden) _destroy input
        citation_topic_list.append($('<input hidden name="' + base_class + '[citation_topics_attributes][' +  citation_topic_index + '][id]" value="' + citation_topic_id + '" >') );
        citation_topic_list.append($('<input hidden name="' + base_class + '[citation_topics_attributes][' +  citation_topic_index + '][_destroy]" value="1" >') );

        // Provide a warning that the list must be saved to properly delete the records, tweak if we think necessary
        warn_for_citation_topic_save(citation_topic_list.siblings('.citation_topic_picker_message'));
      }
    }
    list_item.remove();
  });
};

function warn_for_citation_topic_save(msg_div) {
  msg_div.addClass('warning');
  msg_div.html('Update required to confirm removal/reorder.');
}

//
// Initialize the widget
//
function initialize_citation_topic_picker(form) { // initialize_citation_topic_picker
  // turn the input into an jQuery autocompleter
  // https://jqueryui.com/autocomplete/ 
  //
  initialize_citation_topic_autocomplete(form);
  bind_new_topic_link(form);
  bind_topic_label_mirroring(form);
  bind_remove_citation_topic_links(form.find('.remove_citation_topic'));
  bind_definition_listener(form); 
};


var _initialize_citation_topic_widget;
_initialize_citation_topic_widget = function
  init_citation_topic_picker() {
    $('.citation_topic_picker').each( function() {
      initialize_citation_topic_picker($(this)); 
    });
};

$(document).ready(_initialize_citation_topic_widget);

