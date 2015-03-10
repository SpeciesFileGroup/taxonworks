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
    google.maps.event.addListener(drawingManager, 'polygoncomplete', function (polygon) {
            var feature = [];
            var coordinates = [];
            var geometry = [];
            coordinates = (polygon.getPath().getArray());
            var v = 0;
            for (var i = 0; i < coordinates.length; i++) {
                geometry.push('[' + coordinates[i].lat().toString() + ', ' + coordinates[i].lng().toString() + ']');
            }
            feature.push({
                "type": "Feature",
                "geometry": {
                    "type": "Polygon",
                    "coordinates": geometry.toString()
                }
            });
            $("#map_coords").html(JSON.stringify(feature[0]));
            $("#geoType").text(feature[0]["geometry"]["type"]);
            $("#georeference_geographic_item_attributes_type").val(feature[0]["geometry"]["type"]);
            $("#geoShape").text(feature[0]["geometry"]["coordinates"]);
            $("#georeference_geographic_item_attributes_shape").val(feature[0]["geometry"]["coordinates"]);


            //$("#hiddenGeo").text($("#geoType").text());
            //$("#iframe_response").text($("#geoShape").text());

            //    var hashy = {"coordinates": "abcd", "type": "polygon"};
            //    //$.get('collect_item', JSON.stringify(feature[0].geometry.coordinates), function(){}, 'json');
            //    $.get('collect_item', feature[0], function (local_data) {
            //            map.data.forEach(function (feature) {
            //                map.data.remove(feature);
            //            });    // clear the map.data
            //
            //            map.data.addGeoJson(local_data['feature_collection']);      // add the geo features corresponding to the forms
            //
            //            var data = local_data['feature_collection'];
            //            var bounds = {};
            //            get_Data(data, bounds);
            //            var center_lat_long = get_window_center(bounds);
            //            map.setCenter(center_lat_long);
            //            map.setZoom(bounds.gzoom);
            //            //map.fitBounds(bounds.box);
            //        },
            //        'json' // I expect a JSON response
            //    );
        }
    );
    //google.maps.event.addListener(drawingManager, 'overlaycomplete', function(overlay) {
    //        var feature = [];
    //        var coordinates = [];
    //        var geometry = [];
    //        coordinates = overlay.overlay.getPath().getArray();
    //        for (var i = 0; i < coordinates.length; i++) {
    //            geometry.push([coordinates[i].lat(), coordinates[i].lng()]);
    //        }
    //        feature.push({
    //            "type": "Feature",
    //            "geometry": {
    //                "type": overlay.type,
    //                "coordinates": geometry
    //            }
    //        });
    //        var alt = [];
    //        alt.push({
    //            "type": "Feature",
    //            "geometry": {
    //                "type": overlay.type,
    //                "coordinates": google.maps.geometry.encoding.encodePath(coordinates)
    //            }
    //        });
    //        var u = 0;
    //
    //    }
    //);
    //google.maps.event.addListener(map.DrawingManager, 'circlecomplete', function(circle) {
    //        var coordinates = [];
    //        coordinates = (circle.overlay.getPath().getArray());
    //    }
    //);

}

function addDrawingListeners(map, event) {
    return true;
}
