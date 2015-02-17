

function initGAmap()        // initialization function for geographic area map
{

    if (document.getElementById('feature_collection') != null)  {
        var newfcdata = $("#feature_collection");
        var fcdata = newfcdata.data('feature-collection');

        initialize("map_canvas", data);
        //add_map_listeners();
    }
}


//        $(document).on('page:load', IMAML());
//             add_map_listeners();
