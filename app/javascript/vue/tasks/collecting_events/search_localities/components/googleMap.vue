<template>
  <div :style="{ height: height, width: width }"/>
</template>

<script>
  export default {
    props: {
      height: {
        type: [String, Number],
        default: '512px'
      },
      width: {
        type: [String, Number],
        default: '1024px'
      },
      lat: {
        type: Number,
        required: false,
        default: 0
      },
      lng: {
        type: Number,
        required: false,
        default: 0
      },
      zoom: {
        type: Number,
        default: 2
      },
      shapes: {
        type: Object,
        default: () => { return {} }
      },
      circleOptions: {
        type: Object,
        default: () => {
          return {
            fillColor: '#ffff00',
            fillOpacity: 0.2,
            strokeWeight: 1,
            clickable: false,
            editable: true,
            zIndex: 1
          }
        }
      },
      polygonOptions: {
        type: Object,
        default: () => {
          return {
            fillColor: '#ffff00',
            fillOpacity: 0.2,
            strokeWeight: 1,
            clickable: false,
            editable: true,
            zIndex: 1
          }
        }
      },
      markerOptions: {
        type: Object,
        default: () => {
          return {
            fillColor: '#ffff00',
            fillOpacity: 0.2,
            strokeWeight: 1,
            clickable: false,
            editable: true,
            zIndex: 1
          }
        }
      },
      polylineOptions: {
        type: Object,
        default: () => {
          return {
            fillColor: '#ffff00',
            fillOpacity: 0.2,
            strokeWeight: 1,
            clickable: false,
            editable: true,
            zIndex: 1
          }
        }
      },
      drawingMode: {
        type: String,
        default: ''
      }
    },
    data() {
      return {
        drawingManager: undefined,
        shape: undefined,
        overlay: undefined,
        drawingModes: ['marker', 'circle', 'polygon', 'polyline'],
        map: undefined,
        markers: []
      }
    },
    watch: {
      shapes: {
        handler(newVal) {
          if(this.overlay)
            this.removeFromMap(this.overlay)

          for (var i = 0; i < this.markers.length; i++) {
            this.map.data.remove(this.markers[i])
          }

          this.markers = this.map.data.addGeoJson(newVal)

        },
        deep: true
      }
    },
    mounted() {
      TW.vendor.lib.google.maps.loadGoogleMapsAPI().then(() => {
        this.initMap()
        this.listenEvents()
      })
    },
    methods: {
      initMap() {
        this.map = new google.maps.Map(this.$el, {
          center: {lat: (isNaN(this.lat) ? 0 : this.lat), lng: (isNaN(this.lng) ? 0 : this.lng)},
          zoom: this.zoom
        });
        this.map.data.setStyle({
          fillColor: '#ffff00',
          fillOpacity: 0.2,
          strokeWeight: 1,
        })

        this.drawingManager = new google.maps.drawing.DrawingManager({
          drawingControl: true,
          drawingMode: this.drawingMode,
          drawingControlOptions: {
            position: google.maps.ControlPosition.TOP_CENTER,
            drawingModes: this.drawingModes,
          },
          circleOptions: this.circleOptions,
          polygonOptions: this.polygonOptions,
          markerOptions: this.markerOptions,
          polylineOptions: this.polylineOptions
        });
        this.drawingManager.setMap(this.map);
      },
      listenEvents() {
        let that = this
        google.maps.event.addListener(this.drawingManager, 'overlaycomplete', function (event) {
          if(that.overlay)
            that.removeFromMap(that.overlay)
          that.overlay = event.overlay
          that.shape = JSON.stringify(that.buildFeatureCollectionFromShape(event))
          that.$emit('shape', that.shape)
        })
      },
      removeFromMap(overlay) {
        overlay.setMap(null)
      },
      buildFeatureCollectionFromShape: function (shape) {

        let feature = [];
        let coordinates = [];
        let coordList = [];
        let geometry = [];
        let overlayType = shape.type;
        let radius = undefined;
        shape = shape.overlay

        switch (overlayType) {
          case 'polyline':
            overlayType = 'LineString';
            break;
          case 'polygon':
            overlayType = 'Polygon';
            break;
          case 'marker':
            overlayType = 'Point';
            coordinates.push(shape.position);
            break;
          case 'circle':
            overlayType = 'Point';
            coordinates.push(shape.center);
            radius = shape.radius;
            break;
        }

        if (coordinates.length == 0) {      // 0 if not a point or circle, coordinates is empty
          coordinates = shape.getPath().getArray();     // so get the array from the path

          for (var i = 0; i < coordinates.length; i++) {      // for LineString or Polygon
            geometry.push([coordinates[i].lng(), coordinates[i].lat()]);
          }

          if (overlayType == 'Polygon') {
            geometry.push([coordinates[0].lng(), coordinates[0].lat()]);
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
        if (radius != undefined) {
          feature[0]['properties'] = {"radius": radius};
        }
        return feature[0]
      },
    }
  }
</script>