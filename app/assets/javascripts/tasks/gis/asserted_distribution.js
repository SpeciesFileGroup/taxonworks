

function initADmap()
{

   if (document.getElementById('feature_collection') != null)  {
        var newadwidget = $("#feature_collection");
        var fcdata = newadwidget.data('feature-collection');

        var map = initialize("map_canvas", fcdata);
        add_map_listeners(map);
   }
}


//        $(document).on('page:load', IMAML());
//             add_map_listeners();
