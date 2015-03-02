function initializeDrawItem(map_canvas, fgdata) {
    var mapOptions = {
        center: new google.maps.LatLng(40, -88),
        zoom: 3
    };

    var map = new google.maps.Map(document.getElementById(map_canvas),
        mapOptions);

    var drawingManager = new google.maps.drawing.DrawingManager({
        drawingMode: google.maps.drawing.OverlayType.MARKER,
        drawingControl: true,
        drawingControlOptions: {
            position: google.maps.ControlPosition.TOP_CENTER,
            drawingModes: [
                google.maps.drawing.OverlayType.MARKER,
                google.maps.drawing.OverlayType.CIRCLE,
                google.maps.drawing.OverlayType.POLYGON,
                google.maps.drawing.OverlayType.POLYLINE//,
             //   google.maps.drawing.OverlayType.RECTANGLE
            ]
        },
        markerOptions: {
            icon: '/app/assets/javascripts/mapicons/mm_20_red.png'
        },
        circleOptions: {
            fillColor: '#66cc00',
            fillOpacity: 0.3,
            strokeWeight: 1,
            clickable: false,
            editable: true,
            zIndex: 1
        },
        polygonOptions: {
            fillColor: '#880000',
            fillOpacity: 0.3,
            editable: true,
            strokeWeight: 1,
            strokeColor: 'black'
        },
        polylineOptions: {
            fillColor: '#880000',
            fillOpacity: 0.3,
            editable: true,
            strokeWeight: 1,
            strokeColor: 'black'
        }
    });
    drawingManager.setMap(map);
    google.maps.event.addListener(drawingManager, 'overlaycomplete', function(overlay) {
            var coordinates = [];
            coordinates = overlay.overlay.getPath().getArray();
            var Json = coordinates.toGeoJson(function(){});
        }
    );
    google.maps.event.addListener(drawingManager, 'polygoncomplete', function(polygon) {
            var coordinates = [];
            coordinates = (polygon.overlay.getPath().getArray());
        }
    );
    //google.maps.event.addListener(map.DrawingManager, 'circlecomplete', function(circle) {
    //        var coordinates = [];
    //        coordinates = (circle.overlay.getPath().getArray());
    //    }
    //);

}

function addDrawingListeners(map, event) {
return true;
}