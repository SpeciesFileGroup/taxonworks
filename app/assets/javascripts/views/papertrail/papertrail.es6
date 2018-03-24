PAPERTRAIL = {
    versions_selected: 0,
    $versions: null,
    $version_checkboxes: null,
    $version_detail_checkboxes: null,
    $prev_version_checkbox: null,
    $button_select: null,
    $button_compare: null,
    $user_checkboxes: null,

    initialize: function(){
        PAPERTRAIL.$versions = $(".papertrail_box");
       
        // If no elements with class ".papertrail_box" found it must mean
        // that we're not on the papertrail page and should not attach events
        // to the current page
        if(PAPERTRAIL.$versions.length == 0)
            return false;

        // User checkboxes
        PAPERTRAIL.$user_checkboxes = $(".user_item");
        PAPERTRAIL.$user_checkboxes.click(PAPERTRAIL.update_versions_list);
        PAPERTRAIL.$user_checkboxes.prop("checked", true);

        // Compare buttons
        PAPERTRAIL.$button_select = $("#button_select");
        PAPERTRAIL.$button_compare = $("#button_compare_selected");

        PAPERTRAIL.$button_select.click(PAPERTRAIL.button_select_clicked);
        PAPERTRAIL.$button_compare.click(PAPERTRAIL.button_compare_clicked);

        // Version checkboxes
        PAPERTRAIL.$version_checkboxes = $(".version_checkbox");
        PAPERTRAIL.$version_checkboxes.hide();

        PAPERTRAIL.$version_checkboxes.click(function(e){
            e.stopPropagation();
            PAPERTRAIL.checkbox_clicked($(this));
        });

        PAPERTRAIL.$versions.click(function(){
            let $checkbox = $(this).find(".version_checkbox");

            $checkbox.prop("checked", !$checkbox.prop("checked"));
            PAPERTRAIL.checkbox_clicked($checkbox);
        });
        
        // Version detail checkboxes
        PAPERTRAIL.$version_detail_checkboxes = $(".version_detail_checkbox");
        PAPERTRAIL.$version_detail_checkboxes.css("visibility", "hidden");

        // Restore buttons
        $(".button_confirm_restore").hide();
        
        $(".button_confirm_restore").click(function(){
            PAPERTRAIL.button_confirm_restore_clicked($(this))
        });
        
        $(".button_restore_mode").click(function(){
            PAPERTRAIL.button_restore_mode_clicked($(this));
        });

        // Set up the datepickers and callbacks
        $(".datepicker").datepicker();
        $("#start_datepicker, #end_datepicker").on('change', function() {
            PAPERTRAIL.update_versions_list();
        })
        //$(".datepicker").change(PAPERTRAIL.update_versions_list);

        $("#start_datepicker").val(PAPERTRAIL.get_oldest_version_date());
        $("#end_datepicker").val(get_todays_date());

        // Update the versions list for the first time
        PAPERTRAIL.update_versions_list();
    },

    // Shows/Hides papertrail version based on user filter list criteria
    update_versions_list: function(){
        PAPERTRAIL.exit_compare_mode();

        let user_names = PAPERTRAIL.get_users_from_list();
        let dates = PAPERTRAIL.get_dates();
        // Iterate over each version checking it against users and dates from the filter box
        for(let version_index = 0; version_index < PAPERTRAIL.$versions.length; version_index++){
            let hide = false;
            let $version = $(PAPERTRAIL.$versions[version_index]);
            let version_date = new Date($version.data("date-created").replace(/-/g, "/"));

            // Hide papertrials NOT within the specified dates
            if(dates.start && dates.start > version_date)
                hide = true;

            if(dates.end && dates.end < version_date)
                hide = true;

            // Hide papertrails modified by users in the filter list
            if(!hide){
                let found = false;

                for(let user_id_index = 0; user_id_index < user_names.length; user_id_index++){
                    if(user_names[user_id_index] === $version.data("user-name")){
                        found = true;
                        break;
                    }
                }

                hide = !found;
            }

            // Show/Hide stuff if it matched filter
            if(hide)
                $version.hide();

            else
                $version.show();
        }
    },

    // Gets all the user names from checkboxes that are checked
    // in the user filter list
    // Returns array of user ids
    get_users_from_list: function(){
        let user_names = [];

        for(let i = 0; i < PAPERTRAIL.$user_checkboxes.length; i++)
            if(PAPERTRAIL.$user_checkboxes[i].checked)
                user_names.push(PAPERTRAIL.$user_checkboxes[i].getAttribute("data-user-name"));

        return user_names;
    },

    // Gets the dates from the filter box
    // Returns an object with members start and end
    // which contain the start and end dates.
    // If a date is not parseable the respective member is null
    // or if start date is button_select_clicked after end date they are both null
    get_dates: function(){
        let start_date = null;
        let end_date = null;
        let start_date_valid = is_valid_date($("#start_datepicker").val());
        let end_date_valid = is_valid_date($("#end_datepicker").val());
        let $datepicker_error_message = $("#datepicker_error_message");
        let date_error_message = "";

        if(start_date_valid){
            start_date = new Date($("#start_datepicker").val());
            start_date.setHours(0, 0, 0, 0);
        }

        else
            date_error_message += "Invalid start date<br>";

        if(end_date_valid){
            end_date = new Date($("#end_datepicker").val());
            end_date.setHours(23, 59, 59, 999);
        }

        else
            date_error_message += "Invalid end date<br>";

        if(start_date_valid && end_date_valid){
            if(start_date > end_date){
                date_error_message = "Error: Start date is after end date<br>";
                
                start_date = null;
                end_date = null;
            }
        }

        $datepicker_error_message.html(date_error_message);

        return {start: start_date, end: end_date};
    },

    // Enter/Exit restore mode
    button_restore_mode_clicked: function($button){
        // Exit compare mode
        PAPERTRAIL.exit_compare_mode();

        let $prev_button_restore_mode = $(".restore_mode_active");
       
        // Check if we're already in restore mode
        if($prev_button_restore_mode.length > 0){
            
            // Is the button that was clicked the one with the restore mode active
            // If so just exit restore mode
            if($button.hasClass("restore_mode_active"))
                PAPERTRAIL.exit_restore_mode();

            // Else exit the previous restore mode and enter restore mode
            // with this button aka this papertrail version
            else{
                PAPERTRAIL.exit_restore_mode();
                PAPERTRAIL.enter_restore_mode($button);
            }
        }

        else
            PAPERTRAIL.enter_restore_mode($button);
    },

    // Shows all checkboxes for a papertrail version and
    // sets them all to checked. Adds a "restore_mode_active"
    // css class to the button that was clicked, changes the 
    // text for that button to "Cancel Restore", shows the 
    // confirm restore button, adds "show_confirm_restore_button" css class
    enter_restore_mode: function($button){
        let key = $button.data("papertrail-index");
        let $checkboxes = $(".version_detail_checkbox_" + key);
        
        // Show all checkboxes for a papertrail version and set them to checked
        $checkboxes.css("visibility", "visible");
        $checkboxes.prop("checked", true);

        // Add css class and change text for the button
        $button.addClass("restore_mode_active");
        $button.html("Cancel Restore");

        // Show confirm restore button for that papertrail version
        let button_confirm = $("#button_confirm_restore_" + key);
        button_confirm.addClass("show_confirm_restore_button");
        button_confirm.show();
    },

    // Hides all checkboxes, remove css class "restore_mode_active" from
    // button that was clicked, remove css class "show_confirm_restore_button"
    // from restore button.
    exit_restore_mode: function(){
        // Hide all checkboxes
        PAPERTRAIL.$version_detail_checkboxes.css("visibility", "hidden");

        // Reset restore button text and remove css class
        let $button_restore = $(".restore_mode_active");

        $button_restore.removeClass("restore_mode_active");
        $button_restore.html("Restore");

        // Hide confirm restore button and remove css class
        let $button_confirm_restore = $(".show_confirm_restore_button");

        $button_confirm_restore.removeClass("show_confirm_restore_button");
        $button_confirm_restore.hide();
    },

    // Updates the object with the selected attributes of the current papertrail version
    button_confirm_restore_clicked: function($button){
        // Get all selected attributes to update with
        let key = $button.data("papertrail-index");

        let key_values = $("input:checkbox:checked.version_detail_checkbox_" + key).map(function(){
            let $self = $(this);

            return { key: $self.data("key"), value: $self.data("value") };
        });

        let $papertrail_header = $("#papertrail_header");
        let url_data = {"attributes": {}};

        url_data["object_id"] = $papertrail_header.data("object-id");
        url_data["object_type"] = $papertrail_header.data("object-type");
        
        for(let i = 0; i < key_values.length; i++)
            url_data["attributes"][key_values[i].key] = key_values[i].value;

        PAPERTRAIL.ajax_update(url_data);
    },

    // Makes an ajax update put request with "url_data" as the data,
    // also redirects the page to the papertrail version page of the
    // object that was updated
    // Format for url_data must include
    //      object_id: num
    //      object_type: string
    //      attributes: {}
    ajax_update: function(url_data){
        $.ajax({
            type: 'PUT',
            url: "/papertrail/update",
            dataType: 'json',
            data: url_data
        }).done(function(resp){
            window.location = resp.url;
        });
    },

    // Shows/Hides the compare button and version checkboxes
    button_select_clicked: function(){
        // Exit restore mode
        PAPERTRAIL.exit_restore_mode();

        // Show compare button and version checkboxes
        if(PAPERTRAIL.$button_select.data("select-mode") === 0)
            PAPERTRAIL.enter_compare_mode();

        // Hide compare button and version checkboxes
        else
            PAPERTRAIL.exit_compare_mode();
    },

    // Show compare button and version checkboxes
    enter_compare_mode: function(){
        PAPERTRAIL.versions_selected = 0;
        PAPERTRAIL.$version_checkboxes.prop("checked", false);
        PAPERTRAIL.$version_checkboxes.show();
        PAPERTRAIL.$button_compare.show();
        PAPERTRAIL.$button_compare.prop("disabled", true);
        PAPERTRAIL.$button_select.html("Cancel select to compare");
        PAPERTRAIL.$button_select.data("select-mode", 1);
    },

    // Hide compare button and version checkboxes
    exit_compare_mode: function(){
        PAPERTRAIL.$version_checkboxes.hide();
        PAPERTRAIL.$button_compare.hide();
        PAPERTRAIL.$button_select.html("Select to compare");
        PAPERTRAIL.$button_select.data("select-mode", 0);
    },

    // Go to the compare view with the selected versions 
    button_compare_clicked: function(){
        let version_ids = [];

        for(let i = 0; i < PAPERTRAIL.$version_checkboxes.length; i++)
            if(PAPERTRAIL.$version_checkboxes[i].checked)
                version_ids.push($(PAPERTRAIL.$version_checkboxes[i]).data("version-index"));

        if(version_ids.length < 2)
            version_ids.push(-1);
            
        let new_url = window.location.origin + window.location.pathname;
        new_url += "/compare" + window.location.search;
        new_url += "&version_a=" + version_ids[0];
        new_url += "&version_b=" + version_ids[1];
    
        window.location = new_url;
    },

    // Only allows at most 2 checkboxes to be checked at a time
    checkbox_clicked: function($checkbox){
        if($checkbox.prop("checked")){
            PAPERTRAIL.versions_selected++;

            if(PAPERTRAIL.versions_selected == 1)
                PAPERTRAIL.$button_compare.prop("disabled", false);

            else if(PAPERTRAIL.versions_selected >= 3){
                PAPERTRAIL.$prev_version_checkbox.prop("checked", false);
                PAPERTRAIL.versions_selected = 2;
            }

            PAPERTRAIL.$prev_version_checkbox = $checkbox;
        }

        else{
            PAPERTRAIL.versions_selected--;

            if(PAPERTRAIL.versions_selected == 0)
                PAPERTRAIL.$button_compare.prop("disabled", true);
        }
    },

    // Returns date string for the first of the oldest version,
    // string format 'mm/dd/yyyy'
    get_oldest_version_date: function(){
        // This assumes that the last element in the version list is the oldest
        // This is dependant on the order that the version list is passed
        // into the papertrail partial
        let date_string = PAPERTRAIL.$versions[PAPERTRAIL.$versions.length - 1].getAttribute("data-date-created");
        return convert_date_to_string_underscore(new Date(date_string));
    }
};

$(document).on('turbolinks:load', PAPERTRAIL.initialize);