

function initDrawItem(canvas)
{
    if (canvas.length) {    //preempt omni-listener affecting wrong canvas
        if ($('#feature_collection').length) {
                var newDrawWidget = $("#feature_collection");
                //var fcdata = newDrawWidget.data('feature-collection');

          var map = TW.vendor.google.maps.draw.initializeGoogleMapWithDrawManager(newDrawWidget);
          TW.vendor.google.maps.draw.addDrawingListeners(map);
            }
        }
    }
/*
function initDrawItem(canvas)
{
    if (document.getElementById('feature_collection') != null)  {
        var newDrawWidget = $("#feature_collection");
        var fcdata = newDrawWidget.data('feature-collection');

        var map = initializeGoogleMap(canvas, fcdata);
        addDrawingListeners(map);
    }
}
*/
