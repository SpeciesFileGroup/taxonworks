

function initADmap()
{

   if (document.getElementById('feature_collection') != null)  {
        var newadwidget = $("#feature_collection");
        var fcdata = newadwidget.data('feature-collection');

        initialize("map_canvas", fcdata);
        add_map_listeners();
   }
}


//        $(document).on('page:load', IMAML());
//             add_map_listeners();
