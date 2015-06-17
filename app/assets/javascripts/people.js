function clear_role_picker(picker) {
    // empties search text box and hides new_person div
    $(picker).val("");
    //$("#autocomplete").val("");
    //$("#autocomplete").text("");
    $('#new_person').attr("hidden", true);
}

var _initialize_role_picker_widget;

_initialize_role_picker_widget = function
    init_role_picker() {

    $("#autocomplete").autocomplete({
        source: '/people/lookup_person',
        select: function (event, ui) {
            // execute on select event in search text box

            // add name to list
            $("#author_list").append($('<li>').append(ui.item.value))
            // clear search form
            clear_role_picker(this);
            return false;
        }
    });

    $("#autocomplete").keyup(function () {
        // copies search textbox content to new_person name_label
        var input_term = $("#autocomplete").val();
        if (input_term.length == 0) {
            //alert('hello');
            $('#new_person').attr("hidden", true);
        }
        else {
            $('#new_person').removeAttr("hidden");
        }
        $("#name_label").html(input_term);
    });

    $("#expand").click(function () {
        // alternately hides and displays person_form
        $("#person_form").toggle();
    });

};

$(document).ready(_initialize_role_picker_widget);
$(document).on("page:load", _initialize_role_picker_widget);
