<template>
  <div class="find-ce">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h2>Find collecting events by geographic area or shape</h2>
    <mode-switch v-model="mode"/>
    <div v-if="mode==='list'">
      <table>
        <tr
          v-for="(item, index) in geographicAreaList"
          :key="item.id">
          <td>
            <a
              v-html="item.label_html"
              @click="showObject()"/>
          </td>
          <td><span class="remove_area" data-icon="trash" @click="delistMe(index)"/></td>
        </tr>
      </table>
      <autocomplete
        class="separate-bottom"
        url="/geographic_areas/autocomplete"
        min="2"
        ref="autocomplete"
        param="term"
        placeholder="Select a named geographic area"
        label="label_html"
        @getItem="addGeographicArea($event)"
        :autofocus="true"
        :clear-after="true"
      />
      <input
        type="button" class="button normal-input button-default separate-left"
        @click="getAreaData()"
        :disabled="!geographicAreaList.length"
        value="Find">
    </div>
    <div v-if="mode==='map'">
      <l-map
        height="512px"
        width="1024px"
        :zoom="2"
        ref="leaflet"
        :geojson="geojsonFeatures"
        @geoJsonLayerCreated="shapes.push(JSON.stringify($event));"
        @geoJsonLayersEdited="editedShape($event)"
        :draw-controls="true"
      />
      <!--@geoJsonLayerCreated="getShapesData($event)"-->
      <input
        class="button normal-input button-default separate-left"
        type="button"
        @click="getShapesData()"
        :disabled="!shapes.length"
        value="Find">
    </div>
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'
  import lMap from 'components/leaflet/map.vue'
  import ModeSwitch from './mode_switch'
  import Spinner from 'components/spinner'

  export default {
    components: {
      Autocomplete,
      lMap,
      ModeSwitch,
      Spinner,
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
        shapes: [],   // intended for eventual multiple shapes paradigm
        mode: 'list',
        isLoading: false,
        newFeatures:  [],
        geojsonFeatures: [    // trans-antimeridian polygon test features
    /*      {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [-116.848889, 33.478056, 1066.8]
            }, "properties": {"georeference": {"id": 5, "tag": "Georeference ID = 5"}}
          },
          {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [-154, 69, 0]
            }, "properties": {"georeference": {"id": 42477, "tag": "Georeference ID = 42477"}}
          },
          {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [-158.32, 68.246, 0]
            }, "properties": {"georeference": {"id": 95395, "tag": "Georeference ID = 95395"}}
          },
          {
            "type": "Feature",
            "geometry": {
              "type": "Polygon",
              "coordinates": [[[-128.67480397224426, 70.99598264111805, 0], [162.59472727775574, 68.69703692453726, 0], [-125.68652272224426, 62.48255407659341, 0], [-128.67480397224426, 70.99598264111805, 0]]]
            }, "properties": {"georeference": {"id": 127782, "tag": "Georeference ID = 127782"}}
          },
          {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [-103.43093455511473, 38.50019222109752, 0]
            }, "properties": {"georeference": {"id": 127831, "tag": "Georeference ID = 127831"}}
          },
          {
            "type": "Feature",
            "geometry": {
              "type": "Polygon",
              "coordinates": [[[-64.75905955511473, 54.33201931226469, 0.0], [-65.46218455511473, 42.7665216514439, 0.0], [8.365940444885268, 42.7665216514439, 0.0], [6.256565444885268, 55.93947018491859, 0.0], [-64.75905955511473, 54.33201931226469, 0.0]]]
            }, "properties": {"georeference": {"id": 127832, "tag": "Georeference ID = 127832"}}
          },
          {
            "type": "Feature",
            "geometry": {
              "type": "Polygon",
              "coordinates": [[[-17.18523647139955, 21.406372377910248, 0.0], [-17.88836147139955, 14.386094188926648, 0.0], [55.87162720280878, 13.385314749878527, 0.0], [56.57475220280878, 21.42849772341781, 0.0], [-17.18523647139955, 21.406372377910248, 0.0]]]
            },
            "properties": {"georeference": {"id": 127834, "tag": "Georeference ID = 127834"}}
          }
  */
            // {"type":"Feature","geometry":{"type":"Point","coordinates":[-116.848889,33.478056,1066.8]},"properties":{"georeference":{"id":5,"tag":"Georeference ID = 5"}}},
            // {"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-128.67480397224426,70.99598264111805,0.0],[162.59472727775574,68.69703692453726,0.0],[-125.68652272224426,62.48255407659341,0.0],[-128.67480397224426,70.99598264111805,0.0]]]},"properties":{"georeference":{"id":127782,"tag":"Georeference ID = 127782"}}},
            // {"type":"Feature","geometry":{"type":"Point","coordinates":[-103.43093455511473,38.50019222109752,0.0]},"properties":{"georeference":{"id":127831,"tag":"Georeference ID = 127831"}}},
            // {"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-64.75905955511473,54.33201931226469,0.0],[-65.46218455511473,42.7665216514439,0.0],[8.365940444885268,42.7665216514439,0.0],[6.256565444885268,55.93947018491859,0.0],[-64.75905955511473,54.33201931226469,0.0]]]},"properties":{"georeference":{"id":127832,"tag":"Georeference ID = 127832"}}},
            // {"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-3.8193901777350447,54.27578535939862,0.0],[-7.159233927735045,50.5249257423752,0.0],[-0.30376517773504474,43.84757131263736,0.0],[11.825141072264955,48.76086887572222,0.0],[10.155219197264955,54.32707137347205,0.0],[4.090766072264955,55.43927440167163,0.0],[-3.8193901777350447,54.27578535939862,0.0]]]},"properties":{"georeference":{"id":127833,"tag":"Georeference ID = 127833"}}},
            // {"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-17.18523647139955,21.406372377910248,0.0],[-17.88836147139955,14.386094188926648,0.0],[55.87162720280878,13.385314749878527,0.0],[56.57475220280878,21.42849772341781,0.0],[-17.18523647139955,21.406372377910248,0.0]]]},"properties":{"georeference":{"id":127834,"tag":"Georeference ID = 127834"}}}
          // {"type":"Feature","geometry":{"type":"Point","coordinates":[-116.848889,33.478056,1066.8]},"properties":{"georeference":{"id":5,"tag":"Georeference ID = 5"}}},{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-128.67480397224426,70.99598264111805,0],[162.59472727775574,68.69703692453726,0],[-125.68652272224426,62.48255407659341,0],[-128.67480397224426,70.99598264111805,0]]]},"properties":{"georeference":{"id":127782,"tag":"Georeference ID = 127782"}}},{"type":"Feature","geometry":{"type":"Point","coordinates":[-103.43093455511473,38.50019222109752,0]},"properties":{"georeference":{"id":127831,"tag":"Georeference ID = 127831"}}},{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-64.75905955511473,54.33201931226469,0],[-65.46218455511473,42.7665216514439,0],[8.365940444885268,42.7665216514439,0],[6.256565444885268,55.93947018491859,0],[-64.75905955511473,54.33201931226469,0]]]},"properties":{"georeference":{"id":127832,"tag":"Georeference ID = 127832"}}},{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-3.8193901777350447,54.27578535939862,0],[-7.159233927735045,50.5249257423752,0],[-0.30376517773504474,43.84757131263736,0],[11.825141072264955,48.76086887572222,0],[10.155219197264955,54.32707137347205,0],[4.090766072264955,55.43927440167163,0],[-3.8193901777350447,54.27578535939862,0]]]},"properties":{"georeference":{"id":127833,"tag":"Georeference ID = 127833"}}},{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-17.18523647139955,21.406372377910248,0],[-17.88836147139955,14.386094188926648,0],[55.87162720280878,13.385314749878527,0],[56.57475220280878,21.42849772341781,0],[-17.18523647139955,21.406372377910248,0]]]},"properties":{"georeference":{"id":127834,"tag":"Georeference ID = 127834"}}}


        ]
      }
    },
    methods: {
      getAreaData() {
        this.isLoading = true;
        let geo_ids = [];
        this.geographicAreaList.forEach(area => {
          geo_ids.push(area.id)
        });
        let params = {
          spatial_geographic_area_ids: geo_ids
        };
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          this.collectingEventList = response.body;
          if (this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
          this.isLoading = false;
        });
      },
      getShapesData(geojsonShape) {
        this.isLoading = true;
        let shapeText = this.shapes[this.shapes.length - 1];
        let searchShape = JSON.parse(shapeText);
        // alert(shapeText);
        // alert(JSON.stringify((searchShape)));
        let params = {shape: shapeText};  // take only last shape pro tem
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          this.collectingEventList = response.body;
          if (this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
          let ce_ids = [];      // find the georeferences for these collecting_events
          this.collectingEventList.forEach(ce => {
            ce_ids.push(ce.id)
          });
          if (ce_ids.length) {                // if the list has contents
            let cycles = (ce_ids.length / 30) ;  // each item is about 30 characters, make each cycle less than 2000 chars
            let FeatureCollection = {
              "type": "FeatureCollection",
              "features": []
            };
            let that = this;
            let thisSlice = 0;
            let endSlice;
            let finalSlice = ce_ids.length;
            let newFeatures = [];
            this.newFeatures = [];
            for (let i = 0; i < cycles; i++) {
              endSlice = thisSlice + 30;
              if ((thisSlice + 30) > finalSlice) {endSlice = finalSlice + 1}
              params = {
                collecting_event_ids: ce_ids.slice(thisSlice, endSlice)
              };
              this.$http.get('/georeferences.json', {params: params}).then(response => {
                // put thiese geometries on the map as features
                newFeatures = response.body.map(georeference => {
                  return georeference.geo_json
                });
                this.newFeatures = this.newFeatures.concat(newFeatures);
                FeatureCollection.features = FeatureCollection.features.concat(newFeatures);    //since we currently require an array of features
              });
              thisSlice += 30;
            }
            if(searchShape) {FeatureCollection.features.push(searchShape)}
            setTimeout(function() {
            that.geojsonFeatures = that.geojsonFeatures.concat(FeatureCollection.features);}, 300
          )

          }
          this.isLoading = false;
        })
      },
      addGeographicArea(item) {
        this.geographicAreaList.push(item);
      },
      delistMe(index) {
        this.$delete(this.geographicAreaList, index)
      },
      editedShape(shape) {
        this.shapes.push(JSON.stringify(shape[0]))
      }
    },
  }
</script>
