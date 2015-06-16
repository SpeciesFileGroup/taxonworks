var _initialize_role_picker_widget;

_initialize_role_picker_widget = function
    init_role_picker() {

    $( "#person_form" ).toggle();

    $("#autocomplete").autocomplete({
        source: '/people/lookup_person',
        select: function (event, ui) {
            //alert(ui.item.foo);
        }
    });
    $( "#autocomplete").keyup(function(){
        //alert($("#autocomplete").val());
        $( "#name_label" ).html($("#autocomplete").val());
    });

    $( "#expand").click(function(){
        //alert($("#autocomplete").val());
        $( "#person_form" ).toggle();
    });


//alert("My alert");


}

$(document).ready(_initialize_role_picker_widget);
$(document).on("page:load", _initialize_role_picker_widget);
