
// Return a first name, splits on (white) space or comma
function get_first_name(string) {
  var delimiter;
  if(string.indexOf(",") > 1) {delimiter = ","}
  if(string.indexOf(", ") > 1) {delimiter = ", "}
  if(string.indexOf(" ") > 1 && delimiter != ", ") {delimiter = " "}
  return string.split(delimiter, 2)[0];
}

// Return a last name split on (white) space or commma
function get_last_name(string) {
  var delimiter;
  if(string.indexOf(",") > 1) {delimiter = ","}
  if(string.indexOf(", ") > 1) {delimiter = ", "}
  if(string.indexOf(" ") > 1 && delimiter != ", ") {delimiter = " "}
  return string.split(delimiter, 2)[1];
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
    form.find(".role_list").append($('<li>').append(ui.item.value));
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
   
    // unset form fields

    // hide the form field
    // TODO: !! fails after first expand?
    form.find('.new_person').attr("hidden", true);

    // unset autocomplete input box
    // clear_role_picker(this);
    clear_role_picker(form); 
  });
}

function insert_new_person(form) {

  form.find(".role_list").append(   
      $('<li>').append(
        form.find('.name_label').text()
        )
      .append('<input hidden name="source[roles_attributes][4][person_attributes][last_name]"' +
        ' value="' + 'jonesjonesjones' + '" >')
      );
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


//
// Initialize the widget
//
function initialize_role_picker( form, role_type) {
  // turn the input into an jQuery autocompleter
  // https://jqueryui.com/autocomplete/ 
  initialize_autocomplete(form);
  bind_new_link(form);
  bind_switch_link(form);
  bind_expand_link(form);
  bind_label_mirroring(form); 
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
