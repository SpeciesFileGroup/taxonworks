

function initDrawItem(canvas)
{
    if (document.getElementById('feature_collection') != null)  {
        var newDrawWidget = $("#feature_collection");
        var fcdata = newDrawWidget.data('feature-collection');

        var map = initializeDrawItem(canvas, fcdata);
        addDrawingListeners(map);
    }
}
