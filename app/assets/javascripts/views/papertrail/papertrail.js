PAPERTRAIL = {
    versions_selected: 0,
    $versions: null,
    $checkboxes: null,
    $prev_checkbox: null,
    $button_select: null,
    $button_compare: null,

    initialize: function(){
        PAPERTRAIL.$versions = $(".papertrail_box");
       
        // If no elements with class ".papertrail_box" found it must mean
        // that we're not on the papertrail page and should not attach events
        // to the current page
        if(PAPERTRAIL.$versions.length == 0)
            return false;

        PAPERTRAIL.$button_select = $("#button_select");
        PAPERTRAIL.$button_compare = $("#button_compare_selected");

        PAPERTRAIL.$checkboxes = $(".version_checkbox");
        PAPERTRAIL.$checkboxes.hide();

        PAPERTRAIL.$checkboxes.click(function(e){
            e.stopPropagation();
            PAPERTRAIL.checkbox_clicked($(this));
        });

        PAPERTRAIL.$versions.click(function(){
            let $checkbox = $(this).find(".version_checkbox");

            $checkbox.prop("checked", !$checkbox.prop("checked"));
            PAPERTRAIL.checkbox_clicked($checkbox);
        });

        PAPERTRAIL.$button_select.click(function(){
            PAPERTRAIL.button_select_clicked();
        });

        PAPERTRAIL.$button_compare.click(PAPERTRAIL.button_compare_clicked);
        
        // Set up the datepickers and callbacks
        $(".datepicker").datepicker();
        $(".datepicker").change(PAPERTRAIL.update_versions_list);

        // Update versions list when a user has been added to the list
        $(".user_picker_autocomplete").on("autocompleteclose", PAPERTRAIL.update_versions_list);

        // Update versions list when a user has been removed from the list
        $(".user_filter_list").click(function(e){ 
            if($(e.target).hasClass("remove_user_item"))
                PAPERTRAIL.update_versions_list();
        });
    },

    // Shows/Hides papertrail version based on user filter list criteria
    update_versions_list: function(){
        PAPERTRAIL.exit_compare_mode();

        let user_ids = PAPERTRAIL.get_users_from_list();
        let dates = PAPERTRAIL.get_dates();

        // Iterate over each version checking it against users and dates from the filter box
        for(let version_index = 0; version_index < PAPERTRAIL.$versions.length; version_index++){
            let hide = false;
            let $version = $(PAPERTRAIL.$versions[version_index]);
            let version_date = new Date($version.data("date-created"));

            // Hide papertrials NOT within the specified dates
            if(dates.start && dates.start > version_date)
                hide = true;

            if(dates.end && dates.end < version_date)
                hide = true;

            // Hide papertrails modified by users in the filter list
            if(!hide && user_ids.length > 0){
                let found = false;

                for(let user_id_index = 0; user_id_index < user_ids.length; user_id_index++){
                    if(user_ids[user_id_index] === $version.data("user-id")){
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

    // Gets all the user ids in the uscheckeder filter list
    // Returns array of user ids
    get_users_from_list: function(){
        let user_ids = [];
        let $users = $(".user_item");

        for(let i = 0; i < $users.length; i++)
            user_ids.push($($users[i]).data("user-id"));

        return user_ids;
    },

    // Gets the dates from the filter box
    // Returns an object with members start and end
    // which contain the start and end dates.
    // If a date is not parseable the respective member is null
    // or if start date is button_select_clickedafter end date they are both null
    get_dates: function(){
        let start_date = new Date($("#start_datepicker").val());
        let end_date = new Date($("#end_datepicker").val());
        let start_date_valid = !isNaN(start_date.getTime());
        let end_date_valid = !isNaN(end_date.getTime());
        let $datepicker_error_message = $("#datepicker_error_message");

        $datepicker_error_message.text("");
        $datepicker_error_message.hide();

        if(!start_date_valid)
            start_date = null;

        if(!end_date_valid)
            end_date = null;

        if(start_date_valid && end_date_valid){
            if(start_date > end_date){
                $datepicker_error_message.text("Error: Start date is after end date");
                $datepicker_error_message.show();
                
                start_date = null;
                end_date = null;
            }
        }

        return {start: start_date, end: end_date};
    },

    // Shows/Hides the compare button and version checkboxes
    button_select_clicked: function($button_select){

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
        PAPERTRAIL.$checkboxes.prop("checked", false);
        PAPERTRAIL.$checkboxes.show();
        PAPERTRAIL.$button_compare.show();
        PAPERTRAIL.$button_compare.prop("disabled", true);
        PAPERTRAIL.$button_select.html("Cancel select to compare");
        PAPERTRAIL.$button_select.data("select-mode", 1);
    },

    // Hide compare button and version checkboxes
    exit_compare_mode: function(){
        PAPERTRAIL.$checkboxes.hide();
        PAPERTRAIL.$button_compare.hide();
        PAPERTRAIL.$button_select.html("Select to compare");
        PAPERTRAIL.$button_select.data("select-mode", 0);
    },

    // Go to the compare view with the selected versions 
    button_compare_clicked: function(){
        let version_ids = [];

        for(let i = 0; i < PAPERTRAIL.$checkboxes.length; i++)
            if(PAPERTRAIL.$checkboxes[i].checked)
                version_ids.push($(PAPERTRAIL.$checkboxes[i]).data("version-index"));

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
                PAPERTRAIL.$prev_checkbox.prop("checked", false);
                PAPERTRAIL.versions_selected = 2;
            }

            PAPERTRAIL.$prev_checkbox = $checkbox;
        }

        else{
            PAPERTRAIL.versions_selected--;

            if(PAPERTRAIL.versions_selected == 0)
                PAPERTRAIL.$button_compare.prop("disabled", true);
        }
    }
};

$(document).ready(PAPERTRAIL.initialize);