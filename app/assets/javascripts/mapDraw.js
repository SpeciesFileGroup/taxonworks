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
            editable: true
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
            var featureCollection = [];
            var feature = [];
            var coordinates = [];
            var coordList = [];
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
            if (coordinates.length == 0) {      // 0 if not a point or circle, coordinates is empty
                coordinates = overlay.overlay.getPath().getArray();     // so get the array from the path

                for (var i = 0; i < coordinates.length; i++) {      // for LineString or Polygon
                    geometry.push([coordinates[i].lng(), coordinates[i].lat()]);
                    //geometry.push('[' + coordinates[i].lng().toString() + ', ' + coordinates[i].lat().toString() + ']');
                }
                if (overlayType == 'Polygon') {
                    geometry.push([coordinates[0].lng(), coordinates[0].lat()]);
                    //geometry.push('[[' + coordinates[0].lng().toString() + ', ' + coordinates[0].lat().toString() + ']]');
                    coordList.push(geometry);
                }
                else {
                    coordList = geometry;
                }
            }
            else {          // it is a circle or point
                geometry = [coordinates[0].lng(), coordinates[0].lat()];
                coordList = geometry;
            }

            feature.push({
                "type": "Feature",
                "geometry": {
                    "type": overlayType,
                    "coordinates": coordList
                },
                "properties": {}
            });

            // if it is a circle, the radius will be defined, so set the property
            if (radius != undefined) {feature[0]['properties'] = {"radius": radius};}

            // make a full-fledged FeatureCollection for grins
            featureCollection.push({ "type": "FeatureCollection", "features": feature})

            $("#geoType").text(feature[0]["geometry"]["type"])
            $("#geoShape").text(JSON.stringify(feature[0]));
            $("#georeference_geographic_item_attributes_shape").val(JSON.stringify(feature[0]));
            $("#map_coords").html(JSON.stringify(featureCollection[0]));

            document.getElementsByName('commit')[0].disabled = false;
        }
    );
}

function addDrawingListeners(map, event) {
    return true;
}
