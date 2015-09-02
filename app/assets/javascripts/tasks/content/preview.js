var _init_otu_page_layout_selector_widget;

_init_otu_page_layout_selector_widget = function init_otu_page_layout_selector() {

    $("#otu_page_layout_selector").on("ajax:success", function (e, data, status, local_data) {    // second/innermost ajax callback.
            message = local_data.responseJSON['text'];
            if (message.length) {
                $("#otu_page_preview").html(message);    // shove the 3rd phase returning error message into the local form
            }
            else {
                // shove the returning html into the local form
                $("#otu_page_preview").html(local_data.responseJSON['html']);    // shove the 3rd phase returning html into the local form
            }
        }    // end second/innermost ajax callback.
    ).on("ajax:error", function (e, xhr, status, error) {
            $("#otu_page_preview").append("<p>ERROR</p>");
        }
    );
}

$(document).ready(_init_otu_page_layout_selector_widget);
