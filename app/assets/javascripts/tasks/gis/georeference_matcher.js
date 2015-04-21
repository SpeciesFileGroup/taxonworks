var _init_collecting_event_map_widget;

_init_collecting_event_map_widget = function init_collecting_event_map() {
    if ($('#match_georeference_widget').length) {

        var setup = [];
        setup = initializeGoogleMapWithDrawManager("#_draw_ce_form");

        $(".filter-ce").click(function (event) {

            // unhide this form
            $("#_filter_ce_form").removeAttr("hidden");
            // hide everything else:  tag; drawing; recent;
            $("#_tag_ce_form").attr("hidden", true);
            $("#_draw_ce_form").attr("hidden", true);
            $("#_recent_ce_form").attr("hidden", true);
            event.preventDefault();
        });

        $(".tag-ce").click(function (event) {

            // unhide this form
            $("#_tag_ce_form").removeAttr("hidden");
            // hide everything else: filter; drawing; recent;
            $("#_filter_ce_form").attr("hidden", true);
            $("#_draw_ce_form").attr("hidden", true);
            $("#_recent_ce_form").attr("hidden", true);

            event.preventDefault();
        });

        $(".draw-ce").click(function (event) {

            // unhide this form
            $("#_draw_ce_form").removeAttr("hidden");
            // hide everything else: filter; tag; recent;
            $("#_filter_ce_form").attr("hidden", true);
            $("#_tag_ce_form").attr("hidden", true);
            $("#_recent_ce_form").attr("hidden", true);
            _init_collecting_event_map_widget();
            event.preventDefault();
        });

        $(".recent-ce").click(function (event) {

            // unhide this form
            $("#_recent_ce_form").removeAttr("hidden");
            // hide everything else: filter; tag; drawing;
            $("#_filter_ce_form").attr("hidden", true);
            $("#_tag_ce_form").attr("hidden", true);
            $("#_draw_ce_form").attr("hidden", true);

            event.preventDefault();
        });
        $("#submit_recent_ce").click(function (event) {
            $('#how_many').val($('#how_many_recent').val());
            extra = $('form#recent_count').serialize();
            $.get('recent_collecting_events', extra, function (local_data) {
                // what to do with the json we get back....
                $("#_recent_ce_form").attr("hidden", true);
                selecting = $('#_selecting_ce_form');
                selecting.removeAttr('hidden');
                selecting.html(local_data['html']);
            });

            event.preventDefault();
        });

        $(".filter-gr").click(function (event) {

            // unhide this form
            $("#_filter_gr_form").removeAttr("hidden");
            // hide everything else:  tag; drawing; recent;
            $("#_tag_gr_form").attr("hidden", true);
            $("#_draw_gr_form").attr("hidden", true);
            $("#_recent_gr_form").attr("hidden", true);

            event.preventDefault();
        });

        $(".tag-gr").click(function (event) {

            // unhide this form
            $("#_tag_gr_form").removeAttr("hidden");
            // hide everything else: filter; drawing; recent;
            $("#_filter_gr_form").attr("hidden", true);
            $("#_draw_gr_form").attr("hidden", true);
            $("#_recent_gr_form").attr("hidden", true);

            event.preventDefault();
        });

        $(".draw-gr").click(function (event) {

            // unhide this form
            $("#_draw_gr_form").removeAttr("hidden");
            // hide everything else: filter; tag; recent;
            $("#_filter_gr_form").attr("hidden", true);
            $("#_tag_gr_form").attr("hidden", true);
            $("#_recent_gr_form").attr("hidden", true);
            _init_georeference_map_widget();

            event.preventDefault();
        });

        $(".recent-gr").click(function (event) {

            // unhide this form
            $("#_recent_gr_form").removeAttr("hidden");
            // hide everything else: filter; tag; drawing;
            $("#_filter_gr_form").attr("hidden", true);
            $("#_tag_gr_form").attr("hidden", true);
            $("#_draw_gr_form").attr("hidden", true);

            event.preventDefault();
        });

        // this is the find submits ajax request, get's FC response and draws it on the map

        // within above, bind click events to copy FC item to FC item
        // setup = initializeGoogleMapWithDrawManager("#_draw_ce_form");

    }
};

$(document).ready(_init_collecting_event_map_widget);
$(document).on("page:load", _init_collecting_event_map_widget);
