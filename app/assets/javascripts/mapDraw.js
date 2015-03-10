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
    //google.maps.event.addListener(drawingManager, 'polygoncomplete', function (polygon) {
    //        var feature = [];
    //        var coordinates = [];
    //        var geometry = [];
    //        coordinates = (polygon.getPath().getArray());
    //        var v = 0;
    //        for (var i = 0; i < coordinates.length; i++) {
    //            geometry.push('[' + coordinates[i].lat().toString() + ', ' + coordinates[i].lng().toString() + ']');
    //        }
    //    // capture the drawn graphic item
    //        feature.push({
    //            "type": "Feature",
    //            "geometry": {
    //                "type": "Polygon",
    //                "coordinates": geometry.toString()
    //            }
    //        });
    //
    //        $("#geoType").text(feature[0]["geometry"]["type"]);
    //        $("#georeference_geographic_item_attributes_type").val(feature[0]["geometry"]["type"]);
    //        $("#geoShape").text(feature[0]["geometry"]["coordinates"]);
    //        $("#georeference_geographic_item_attributes_shape").val(feature[0]["geometry"]["coordinates"]);
    //    }
    //);
    google.maps.event.addListener(drawingManager, 'overlaycomplete', function(overlay) {
            var featureCollection = [];
            var feature = [];
            var coordinates = [];
            var geometry = [];
            var overlayType = overlay.type[0].toUpperCase() + overlay.type.slice(1);
            var radius = undefined;
            switch(overlayType) {
                case 'Polyline':
                    overlayType = 'LineString';
                    break;
                case 'Marker':
                    overlayType = 'Point';
                    coordinates.push(overlay.overlay.position);
                    break;
                case 'Circle':
                    overlayType = 'Point';
                    coordinates.push(overlay.overlay.center);
                    radius = overlay.overlay.radius;
                    break;
            }
            if (coordinates.length == 0) {
                coordinates = overlay.overlay.getPath().getArray();
            }
            for (var i = 0; i < coordinates.length; i++) {
    //            geometry.push([coordinates[i].lat(), coordinates[i].lng()]);
                geometry.push('[' + coordinates[i].lat().toString() + ', ' + coordinates[i].lng().toString() + ']');
            }

            feature.push({
                "type": "Feature",
                "geometry": {
                    "type": overlayType,
                    "coordinates": geometry.toString()
                }
            });
            if (radius != undefined) {feature[0]['properties'] = {"radius": radius};}
            featureCollection.push({ "type": "FeatureCollection", "features": feature})
            //var alt = [];
            //alt.push({
            //    "type": "Feature",
            //    "geometry": {
            //        "type": overlay.type,
            //        "coordinates": google.maps.geometry.encoding.encodePath(coordinates)
            //    }
            //});
            var u = 0;
            $("#geoType").text(feature[0]["geometry"]["type"])
            $("#geoShape").text(JSON.stringify(feature));
            $("#georeference_geographic_item_attributes_shape").val(JSON.stringify(feature));
            $("#map_coords").html(JSON.stringify(featureCollection));
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
