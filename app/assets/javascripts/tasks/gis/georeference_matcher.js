$(document).on('ready page:load', function () {

    $(".filter-ce").click(function (event) {

        // unhide this form
        $(this).removeAttr("hidden");
        // hide everything else:  tag; drawing; recent;
        $(".tag-ce").attr("hidden", true)
        $(".draw-ce").attr("hidden", true)
        $(".recent-ce").attr("hidden", true)
        event.preventDefault();

        return;
    });
    $(".tag-ce").click(function (event) {

        // unhide this form
        $(this).removeAttr("hidden");
        // hide everything else: filter; drawing; recent;
        $(".filter-ce").attr("hidden", true)
        $(".draw-ce").attr("hidden", true)
        $(".recent-ce").attr("hidden", true)

        event.preventDefault();

        return;
    });
    $(".draw-ce").click(function (event) {

        // unhide this form
        $(this).removeAttr("hidden");
        // hide everything else: filter; tag; recent;
        $(".filter-ce").attr("hidden", true)
        $(".tag-ce").attr("hidden", true)
        $(".recent-ce").attr("hidden", true)

        event.preventDefault();

        return;
    });
    $(".recent-ce").click(function (event) {

        // unhide this form
        $(this).removeAttr("hidden");
        // hide everything else: filter; tag; drawing;
        $(".filter-ce").attr("hidden", true)
        $(".tag-ce").attr("hidden", true)
        $(".draw-ce").attr("hidden", true)

        event.preventDefault();

        return;
    });
    return;
});