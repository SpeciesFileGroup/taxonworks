
// Return a first name, splits on (white) space or comma
function get_first_name(string) {

  // if there is no space or , there is no first name
  if ((string.indexOf(",") > 1) || (string.indexOf(" ") > 1)) {
    var delimiter;
    if(string.indexOf(",") > 1) {delimiter = ","}
    if(string.indexOf(", ") > 1) {delimiter = ", "}
    if(string.indexOf(" ") > 1 && delimiter != ", ") {delimiter = " "}
    return string.split(delimiter, 2)[0];
  } else {
    return null;
  };
}

// Return a last name split on (white) space or commma
function get_last_name(string) {
  // if there no space or comma then the whole string is the *last* name
  if ((string.indexOf(",") > 1) || (string.indexOf(" ") > 1) ) {
    var delimiter;
    if(string.indexOf(",") > 1) {delimiter = ","}
    if(string.indexOf(", ") > 1) {delimiter = ", "}
    if(string.indexOf(" ") > 1 && delimiter != ", ") {delimiter = " "}
    return string.split(delimiter, 2)[1];
  } else {
    return string
  };
}

// Build a name string - first_name and last_name must be strings
function get_full_name(first_name, last_name) {
  var separator = "";
  if (!!last_name && !!first_name) {
    separator = ", ";
  }
  return (last_name + separator + first_name);
}

// Empties search text box and hide new_person div
function clear_role_picker(form) {
  var role_picker;
  role_picker = form.find('.role_picker_autocomplete');
  $(role_picker).val("");
  form.find(".new_person").attr("hidden", true);
}

function initialize_autocomplete(form) {
  var autocomplete_input = form.find(".role_picker_autocomplete");

  autocomplete_input.autocomplete({
    source: '/people/lookup_person',
  open: function (event, ui) {
    bind_hover(); 
  },
  select: function (event, ui) {    // execute on select event in search text box
    // add name to list
    
    // form.find(".role_list").append($('<li>').append(ui.item.value));
    insert_existing_person(form, ui.item.object_id, ui.item.label) 

    // clear search form
    clear_role_picker(form);
    return false;
  }
  }).autocomplete("instance")._renderItem = function (ul, item) {
    return $("<li>")
      .append("<a>" + item.label + " <span class='hoverme'>...</span> " + "</a>")
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
    };

    if (input_term.indexOf(",") > 1) {   //last name, first name format
      var swap = first_name;
      first_name = last_name;
      last_name = swap;
    }

    form.find(".first_name").val(first_name).change();
    form.find(".last_name").val(last_name).change();
  });
};


//
// Binding actions (clicks) to links 
//

function bind_new_link(form) {
  // Add a role to the list via the custom add new box
  form.find(".role_picker_add_new").click(function () {

    insert_new_person(form);
   
    // hide the form field
    // TODO: !! fails after first expand?
    form.find('.new_person').attr("hidden", true);

    // unset autocomplete input box
    // clear_role_picker(this);
    clear_role_picker(form); 
  });
}

function insert_existing_person(form, person_id, label) {
  var role_type = 'Source' + capitalize(form.data('role-type')) ;
  var random_index = new Date().getTime(); 
  var role_list = form.find(".role_list");
  var person_base = 'source[roles_attributes][' + random_index + '][person_attributes]'; 

  // type
  role_list.append( $('<input hidden name="source[roles_attributes][' +  random_index + '][type]" value="' + role_type +  '" >') );
  role_list.append( $('<input hidden name="source[roles_attributes][' +  random_index + '][person_id]" value="' + person_id +  '" >') );

  // TODO: update remove link generation to be the same for both pages
  var remove_link = $('<a href="#" class="remove_role">remove</a>');

  // insert visible list item
  role_list.append( $('<li>').append( label).append('&nbsp;').append(remove_link) );

  bind_remove_links(remove_link);
};

function insert_new_person(form) {
  var role_type = 'Source' + capitalize(form.data('role-type')) ;
  var random_index = new Date().getTime(); 
  var role_list = form.find(".role_list");
  var person_base = 'source[roles_attributes][' + random_index + '][person_attributes]'; 

  var remove_link = $('<a href="#" class="remove_role">remove</a>');

  // type
  role_list.append($('<li class="role_item" data-new-person="true" data-role-id="' + random_index + '" >')
  .append(form.find('.name_label').text() + '&nbsp;' )
  .append( $('<input hidden name="source[roles_attributes][' +  random_index + '][type]" value="' + role_type +  '" >') )

  // names 
  .append( $('<input hidden name="' + person_base + '[last_name]" value="' + form.find(".last_name").val() + '" >') )
  .append( $('<input hidden name="' + person_base + '[first_name]" value="' + form.find(".first_name").val() + '" >') )
  .append( $('<input hidden name="' + person_base + '[suffix]" value="' + form.find(".suffix").val() + '" >') )
  .append( $('<input hidden name="' + person_base + '[prefix]" value="' + form.find(".prefix").val() + '" >') )
  .append(remove_link)
  );

  bind_remove_links(remove_link);
};


function bind_switch_link(form) {
  // click switches the values in the first & last names
  form.find(".role_picker_switch").click(function () {
    var tmp = form.find(".first_name").val();
    form.find(".first_name").val(form.find(".last_name").val()).change();
    form.find(".last_name").val(tmp).change();
  });
};

function bind_expand_link(form) {
  // click alternately hides and displays role_picker_person_form
  form.find(".role_picker_expand").click(function () {
    form.find(".role_picker_person_form").toggle();
  });
}

function bind_label_mirroring(form) {
  // update mirrored label
  form.find(".role_picker_person_form input").on("change keyup", function () {
    form.find(".name_label").html(
      get_full_name(form.find(".first_name").val(), form.find(".last_name").val())
      );

    // build full name out of individual labels
  });
}

// bind a hover event to an ellipsis
function bind_hover() {
  hiConfig = {
    sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
    interval: 400, // number = milliseconds for onMouseOver polling interval
    timeout: 200, // number = milliseconds delay before onMouseOut
    over: function () {
      alert('hi');
    }, // function = onMouseOver callback (REQUIRED)
    out: function () {
      alert('bye');
    } // function = onMouseOut callback (REQUIRED)
  };
  $('.hoverme').hoverIntent(hiConfig);
}

// Bind the remove action/functionality to a links
function bind_remove_links(links) {
  links.click(function () {
    list_item = $(this).parent('li');
    var role_id = list_item.data('role-id');
    if (role_id) {
      var role_list = list_item.closest('.role_list');
     
      // if this is not a new person 
      if (!(list_item.data('new-person')) ) {
        // if there is an ID from an existing item add the necessary (hidden) _destroy input
        role_list.append($('<input hidden name="source[roles_attributes][' +  role_id + '][id]" value="' + role_id + '" >') );
        role_list.append($('<input hidden name="source[roles_attributes][' +  role_id + '][_destroy]" value="1" >') );

        // Provide a warning that the list must be saved to properly delete the records, tweak if we think necessary
        role_list.siblings('.role_picker_header').addClass('subtle');
        role_list.siblings('.role_picker_header').append(' (save required to update removals)');
      }
    }

    list_item.remove();
  });
};


function make_role_list_sortable(form) {
  var list_items = form.find('.role_list');
  list_items.sortable();
  list_items.disableSelection();
}


function bind_position_handling_to_submit_button(form) {
  form.closest('form').find('input[name="commit"]').click(function () {
    var i = 1;
    var role_id;
    form.find('.role_item').each( function() {
      console.log($(this));
      role_id = $(this).data('role-id');
      $(this).append(
        $('<input hidden name="source[roles_attributes][' +  role_id + '][position]" value="' + i + '" >')
        );
      i = i + 1; 
    });
  });
}

//
// Initialize the widget
//
function initialize_role_picker( form, role_type) {
  // turn the input into an jQuery autocompleter
  // https://jqueryui.com/autocomplete/ 
  //
  // all of these should likely be renamed for namespacing purposes
  initialize_autocomplete(form);
  bind_new_link(form);
  bind_switch_link(form);
  bind_expand_link(form);
  bind_label_mirroring(form);
  bind_remove_links(form.find('.remove_role')); 
  make_role_list_sortable(form);
  bind_position_handling_to_submit_button(form);
};

var _initialize_role_picker_widget;

_initialize_role_picker_widget = function
  init_role_picker() {
    $('.role_picker').each( function() {
      var role_type = $(this).data('role-type');
      initialize_role_picker($(this), role_type); 
    });
};

// Initialize the script on page load
$(document).ready(_initialize_role_picker_widget);
$(document).on("page:load", _initialize_role_picker_widget);
