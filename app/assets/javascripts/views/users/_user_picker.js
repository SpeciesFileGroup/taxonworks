/*
Used to select a user from an autocomplete input
*/
USER_PICKER_WIDGET = {

    // Sets up the autocomplete
    initialize_autocomplete: function(form){
        let autocomplete_input = form.find(".user_picker_autocomplete");

        autocomplete_input.autocomplete({
            source: '/users/lookup_user',
            open: function(event, ui){
            },
            select: function(event, ui){
                USER_PICKER_WIDGET.insert_existing_user(form, ui.item.object_id, ui.item.name);
                USER_PICKER_WIDGET.clear_user_picker(form);
                return false;
            }
        }).autocomplete("instance")._renderItem = function(ul, item){
            return $('<li class="autocomplete">')
                // TODO: Do something with this "hoverme" class
                .append("<a>" + item.name + '<span class="hoverme" data-user-id="' + item.object_id + '"></span></a>')
                .appendTo(ul);
        }
    },

    // Clears the user_filter_list 
    clear_user_picker: function(form){
        let user_picker = form.find('.user_picker_autocomplete');
        $(user_picker).val("");
    },

    // Creates a user entry in the user list
    insert_existing_user: function(form, user_id, name){
        let user_filter_list = form.find('.user_filter_list');

        user_filter_list.append($('<li data-user-id="' + user_id + '" class="user_item">')
                                    .append(name).append('&nbsp;')
                                    .append(USER_PICKER_WIDGET.remove_link()));
    },

    // Returns a remove link
    remove_link: function(){
        let link = $('<a href="#" class="remove_user_item">remove</a>');
        USER_PICKER_WIDGET.bind_remove_link(link);
        return link;
    },

    //
    // Binds for various things 
    //

    // Creates a click event for the remove link
    bind_remove_link: function(link){
        link.click(function(){
            $(this).parent('li').remove();
        });
    },

    //
    //  Initialize widget
    //
    initialize_user_picker: function(form){
        USER_PICKER_WIDGET.initialize_autocomplete(form);
    }
};

let _initialize_user_picker_widget = function(){
    $('.user_picker_box').each(function(){
        USER_PICKER_WIDGET.initialize_user_picker($(this));
    });
};

// Initialize script on page load
$(document).ready(_initialize_user_picker_widget);