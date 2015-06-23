//function exists(string) {
//    if (string != undefined && string != "") {
//        return true;}
//    else
//        {
//            return false;
//        }
//    }


function get_first_name(string) {
    // split on (white) space
    return string.split(" ", 2)[0];
}

function get_last_name(string) {
    // split on (white) space
    return string.split(" ", 2)[1];
}

// first_name and last_name must be strings
function get_full_name(first_name, last_name) {
    var separator = "";
    if (!!last_name && !!first_name) {
        //alert("both have values");
        separator = ", ";
    }
    return (last_name + separator + first_name);
    //return ($.grep([last_name, separator, first_name], Boolean).join());
}

function clear_role_picker(target) {
    // empties search text box and hides new_person div

    var role_picker;
    role_picker = $(target).closest("#role_picker").find("#autocomplete");
    $(role_picker).val("");
    //$("#autocomplete").val("");
    //$("#autocomplete").text("");
    $('#new_person').attr("hidden", true);
}

var _initialize_role_picker_widget;

_initialize_role_picker_widget = function
    init_role_picker() {

    $("#add_new").click(function () {
        $("#role_list").append(
            $('<li>').append(
                $("#name_label").text()
            )
        )
        // unset form fields
        // hide the form field
        $('#new_person').attr("hidden", true);
        // unset autocomplete input box
        clear_role_picker(this);
    });

    $("#autocomplete").autocomplete({
        source: '/people/lookup_person',
        select: function (event, ui) {
            // execute on select event in search text box

            // add name to list
            $("#role_list").append($('<li>').append(ui.item.value));
            // clear search form
            clear_role_picker(this);
            return false;
        }
    });

    $("#autocomplete").keyup(function () {
        // copies search textbox content to new_person name_label
        var input_term = $("#autocomplete").val();
        var last_name = get_last_name(input_term);
        var first_name = get_first_name(input_term);

        if (input_term.length == 0) {
            //alert('hello');
            $('#new_person').attr("hidden", true);
        }
        else {
            $('#new_person').removeAttr("hidden");
        }
        $("#person_first_name").val(first_name).change();
        $("#person_last_name").val(last_name).change();
    });

    $("#switch").click(function () {
        // switch the values in the first & last names
        var tmp = $("#person_first_name").val()
        $("#person_first_name").val($("#person_last_name").val()).change();
        $("#person_last_name").val(tmp).change();
    })

    $("#expand").click(function () {
        // alternately hides and displays person_form
        $("#person_form").toggle();
    });

    $("#person_form input").on("change keyup", function () {
        // update mirrored label
        $("#name_label").html(get_full_name($("#person_first_name").val(), $("#person_last_name").val()));
        // build full name out of individual labels
    });

};

$(document).ready(_initialize_role_picker_widget);
$(document).on("page:load", _initialize_role_picker_widget);
