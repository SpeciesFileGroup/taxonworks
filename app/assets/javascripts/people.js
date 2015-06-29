//function exists(string) {
//    if (string != undefined && string != "") {
//        return true;}
//    else
//        {
//            return false;
//        }
//    }

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


 // Enumerate the existing role pickers on this page
 // $('.role_picker').each( function() {

 //   // Get the type of role
 //   var rol_type =  $(this).data('role-type');

 //   // Initialize each one according to its type
 // }); "

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

// first_name and last_name must be strings
function get_full_name(first_name, last_name) {
  var separator = "";
  if (!!last_name && !!first_name) {
    separator = ", ";
  }
  return (last_name + separator + first_name);
}

// Empties search text box and hide new_person div
function clear_role_picker(target) {
  var role_picker;
  role_picker = $(target).closest(".role_picker").find("#autocomplete");
  $(role_picker).val("");

  $(target).closest(".new_person").attr("hidden", true);
  //  $('#new_person').attr("hidden", true);
}

var _initialize_role_picker_widget;

_initialize_role_picker_widget = function
    init_role_picker() {

  // Add a role to the list via the custom add new box
      $("#add_new").click(function () {
        $(this).closest(".role_picker").find(".role_list").append(
          $('<li>').append(
            $("#name_label").text()
            )
          .append('<input hidden name="source[roles_attributes][4][person_attributes][last_name]"' +
            ' value="' + 'jonesjonesjones' + '" >')

          );
        // unset form fields
    // hide the form field

    $(this).closest(".role_picker").find(".new_person").attr("hidden", true);
    //  $('#new_person').attr("hidden", true);
    // unset autocomplete input box
    clear_role_picker(this);
  });

  // Transform input to an autocomplete input
  //   TODO: change to class, use data-role="" to define the role related
  //      properties of the auocomplete
  $("#autocomplete").autocomplete({
    source: '/people/lookup_person',
    open: function (event, ui) {
      bind_hover(); //alert('open');
    },
    select: function (event, ui) {       // execute on select event in search text box
      // add name to list
      $(this).closest(".role_picker").find(".role_list").append($('<li>').append(ui.item.value));

      // clear search form
      clear_role_picker(this);
      return false;
    }
  }).autocomplete("instance")._renderItem = function (ul, item) {
    return $("<li>")
        .append("<a>" + item.label + " <span class='hoverme'>...</span> " + "</a>")
        .appendTo(ul);
  };


  // copies search textbox content to new_person name_label
  $("#autocomplete").keyup(function () {
    var input_term = $("#autocomplete").val();
    var last_name = get_last_name(input_term);
    var first_name = get_first_name(input_term);

    if (input_term.length == 0) {
      //alert('hello');
      $(this).closest(".role_picker").find(".new_person").attr("hidden", true);
//      $('#new_person').attr("hidden", true);
    }
    else {
      $(this).closest(".role_picker").find(".new_person").removeAttr("hidden");
//      $('#new_person').removeAttr("hidden");
    }
    if(input_term.indexOf(",") > 1) {   //last name, first name format
      var swap = first_name;
      first_name = last_name;
      last_name = swap;
    }

    $("#person_first_name").val(first_name).change();
    $("#person_last_name").val(last_name).change();
  });


  // switch the values in the first & last names
  $("#switch").click(function () {
    var tmp = $("#person_first_name").val();
    $("#person_first_name").val($("#person_last_name").val()).change();
    $("#person_last_name").val(tmp).change();
  });

  // alternately hides and displays person_form
  $("#expand").click(function () {
    $("#person_form").toggle();
  });

  // update mirrored label
  $("#person_form input").on("change keyup", function () {
    $("#name_label").html(get_full_name($("#person_first_name").val(), $("#person_last_name").val()));
    // build full name out of individual labels
  });

};

// Initialize the script on page load
$(document).ready(_initialize_role_picker_widget);
$(document).on("page:load", _initialize_role_picker_widget);
