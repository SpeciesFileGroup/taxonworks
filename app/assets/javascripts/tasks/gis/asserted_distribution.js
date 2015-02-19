

function initADmap(canvas1, canvas2)
{

   if (document.getElementById('feature_collection') != null)  {
        var newadwidget = $("#feature_collection");
        var fcdata = newadwidget.data('feature-collection');

        var map1 = initialize(canvas1, fcdata);
        add_map_listeners(map1);
        var map2 = initialize(canvas2, fcdata);
        add_map_listeners(map2);
   }
}
