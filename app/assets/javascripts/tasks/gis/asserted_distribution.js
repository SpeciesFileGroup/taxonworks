

function initADmap(canvas)  //1, canvas2)
{

   if (document.getElementById('feature_collection') != null)  {
        var newadwidget = $("#feature_collection");
        var fcdata = newadwidget.data('feature-collection');

        var map = initialize(canvas, fcdata);
        add_map_listeners(map);
        //map = initialize(canvas2, fcdata);
        //add_map_listeners(map);
   }
}
