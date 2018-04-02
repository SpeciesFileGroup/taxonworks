PAPERTRAIL_COMPARE = {
    $version_detail_checkboxes: null,

    initialize: function(){
        // If no elements with class ".compare_content" found it must mean
        // that we're not on the papertrail compare page and should not attach events
        // to the current page
        if($(".compare_content").length == 0)
            return false;

        // Version detail checkboxes
        PAPERTRAIL_COMPARE.$version_detail_checkboxes = $(".version_detail_checkbox");
        PAPERTRAIL_COMPARE.$version_detail_checkboxes.hide();

        // Restore buttons
        $(".button_confirm_restore").css("visibility", "hidden");
        
        $(".button_confirm_restore").click(function(){
            PAPERTRAIL_COMPARE.button_confirm_restore_clicked($(this))
        });
        
        $(".button_restore_mode").click(function(){
            PAPERTRAIL_COMPARE.button_restore_mode_clicked($(this));
        });
    },

    // Enter/Exit restore mode
    button_restore_mode_clicked: function($button){
        let $prev_button_restore_mode = $(".restore_mode_active");
       
        // Check if we're already in restore mode
        if($prev_button_restore_mode.length > 0){
            
            // Is the button that was clicked the one with the restore mode active
            // If so just exit restore mode
            if($button.hasClass("restore_mode_active"))
                PAPERTRAIL_COMPARE.exit_restore_mode();

            // Else exit the previous restore mode and enter restore mode
            // with this button aka this papertrail version
            else{
                PAPERTRAIL_COMPARE.exit_restore_mode();
                PAPERTRAIL_COMPARE.enter_restore_mode($button);
            }
        }

        else
            PAPERTRAIL_COMPARE.enter_restore_mode($button)
    },

    // Shows all checkboxes for a papertrail version and
    // sets them all to checked. Adds a "restore_mode_active"
    // css class to the button that was clicked, changes the 
    // text for that button to "Cancel Restore", shows the 
    // confirm restore button, adds "show_confirm_restore_button" css class
    enter_restore_mode: function($button){
        let key = $button.data("type");
        let $checkboxes = $(".version_detail_checkbox_" + key);
        
        // Show all checkboxes for a papertrail version and set them to checked
        $checkboxes.show();
        $checkboxes.prop("checked", true);

        // Add css class and change text for the button
        $button.addClass("restore_mode_active");
        $button.html("Cancel Restore");

        // Show confirm restore button for that papertrail version
        let button_confirm = $("#button_confirm_restore_" + key);
        button_confirm.addClass("show_confirm_restore_button");
        button_confirm.css("visibility", "visible");
    },

    // Hides all checkboxes, remove css class "restore_mode_active" from
    // button that was clicked, remove css class "show_confirm_restore_button"
    // from restore button.
    exit_restore_mode: function(){
        // Hide all checkboxes
        PAPERTRAIL_COMPARE.$version_detail_checkboxes.hide();

        // Reset restore button text and remove css class
        let $button_restore = $(".restore_mode_active");

        $button_restore.removeClass("restore_mode_active");
        $button_restore.html("Restore");

        // Hide confirm restore button and remove css class
        let $button_confirm_restore = $(".show_confirm_restore_button");

        $button_confirm_restore.removeClass("show_confirm_restore_button");
        $button_confirm_restore.css("visibility", "hidden");
    },

    // Updates the object with the selected attributes of the current papertrail version
    button_confirm_restore_clicked: function($button){
        // Get all selected attributes to update with
        let key = $button.data("type");

        let key_values = $("input:checkbox:checked.version_detail_checkbox_" + key).map(function(){
            let $self = $(this);

            return { key: $self.data("key"), value: $self.data("value") };
        });

        let $papertrail_compare_header = $("#papertrail_compare_header");
        let url_data = {"attributes": {}};

        url_data["object_id"] = $papertrail_compare_header.data("object-id");
        url_data["object_type"] = $papertrail_compare_header.data("object-type");
        
        for(let i = 0; i < key_values.length; i++)
            url_data["attributes"][key_values[i].key] = key_values[i].value;

        PAPERTRAIL.ajax_update(url_data);
    },
};

$(document).on('turbolinks:load', PAPERTRAIL_COMPARE.initialize);