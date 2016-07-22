PAPERTRAIL = {
     $versions: null,

    initialize: function(){
        PAPERTRAIL.$versions = $(".papertrail_box");

        // If no elements with class ".papertrail_box" found it must mean
        // that we're not on the papertrail page and should not attach events
        // to the current page
        if(PAPERTRAIL.$versions.length == 0)
            return false;

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
        let user_ids = PAPERTRAIL.get_users_from_list();
        let start_date = new Date($("#start_datepicker").val());
        let end_date = new Date($("#end_datepicker").val());

        for(let version_index = 0; version_index < PAPERTRAIL.$versions.length; version_index++){
            let hide = false;
            let $version = $(PAPERTRAIL.$versions[version_index]);
            let version_date = new Date($version.data("date-created"));

            // Hide papertrials NOT within the specified dates
            if(!isNaN(start_date.getTime()) && start_date > version_date)
                hide = true;

            if(!isNaN(end_date.getTime()) && end_date < version_date)
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

    // Gets all the user ids in the user filter list
    get_users_from_list: function(){
        let user_ids = [];
        let $users = $(".user_item");

        for(let i = 0; i < $users.length; i++)
            user_ids.push($($users[i]).data("user-id"));

        return user_ids;
    }
};

$(document).ready(PAPERTRAIL.initialize);