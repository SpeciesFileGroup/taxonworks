function initDrawItem(canvas) {
  if (canvas.length) {    //preempt omni-listener affecting wrong canvas
    var newDrawWidget = $("#feature_collection");
    if (newDrawWidget.length) {
      //var fcdata = newDrawWidget.data('feature-collection');

      var map = TW.vendor.lib.google.maps.draw.initializeGoogleMapWithDrawManager(newDrawWidget);
      TW.vendor.lib.google.maps.draw.addDrawingListeners(map);
    }
  }
}
