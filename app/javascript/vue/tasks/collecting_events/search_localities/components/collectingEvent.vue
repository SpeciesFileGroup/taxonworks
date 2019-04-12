<template>
  <div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h3>Collecting event</h3>
    <smart-selector
      :options="tabs"
      name="collecting_event"
      :add-option="moreOptions"
      v-model="view"/>
    <template>
      <div v-if="view === 'Filter'">
        <ce-filter @collectingEventList="compileList($event)"/>
      </div>
      <div v-else-if="view === 'Named Area Search'">
        <ce-by-area
          @collectingEventList="compileList($event)"
          @featuresList="featuresList=$event"
          @highlightRow="highlightRow=$event"
          @restoreRow="restoreRow=$event"
          :light-row="lightRow"
          :dim-row="dimRow"
          ref="cebyarea"
        />
      </div>
      <div v-else-if="view === 'Drawn Area Search'">
        <ce-by-shape
          @collectingEventList="compileList($event)"
          @featuresList="featuresList=$event"
          @highlightRow="highlightRow=$event"
          @restoreRow="restoreRow=$event"
          :light-row="lightRow"
          :dim-row="dimRow"
          ref="cebyshape"
        />
      </div>
      <div v-else-if="view === 'Tag'">
        <ce-tag @collectingEventList="compileList($event)"/>
      </div>
      <template v-else>
        <table>
          <tr
            v-for="item in showList[view]"
            :key="item.id">
            <td
              v-html="item.cached"/>
          </tr>
        </table>
      </template>
      <input
        type="button"
        @click="removeAllList()"
        value="Reset">
      <input
        type="button"
        @click="processList()"
        value="Add to Map">
    </template>
    <div>
      <div class="annotation_logic separate-left">
        <h2>Collecting Events</h2>
        <annotation-logic v-model="annotation_logic"/>
        <input type="button" @click="selectAllList" value="Select All" />
        <input type="button" @click="deselectAllList" value="Select None" />
        <input type="button" @click="keepSelected" value="remove Unselected" />
        <input type="button" @click="removeAllList" value="Remove All" />


      </div>
      <div>
        <input
          type="checkbox"
          v-model="showResultMap"> Show Map
        <input
          type="checkbox"
          v-model="showResultList"> Show List
      </div>
      <span
        v-if="collectingEventList.length"
        v-html="'<br>' + collectingEventList.length + '  results found.'"/>
    </div>
    <div class="flexbox">
      <div
        class="first-column separate-right"
        v-if="showResultList">
        <table class="full_width">
          <thead>
            <th>Verbatim Locality</th>
            <th v-if="!showResultMap">Date start</th>
            <th v-if="!showResultMap">Date end</th>
            <th v-if="!showResultMap">Country</th>
            <th v-if="!showResultMap">State</th>
            <th>Total objects</th>
            <th v-if="!showResultMap">Pin</th>
            <th v-if="!showResultMap"></th>
            <th> Select </th>
            <th></th>
          </thead>
          <tbody>
            <tr
              v-for="(item, index) in collectingEventList"
              :key="item.id"
              :class="{'ce-row': highlightRow==item.id}"
              @mouseover="lightRow=item.id; dimRow=0"
              @mouseout="dimRow=item.id; lightRow=0"
            >
              <td class="my-column">
                <span
                  v-html="item.id + ' ' + item.verbatim_locality"
                  @click="showObject(item.id)"
                />
              </td>
              <td v-if="!showResultMap">
                <span
                  v-html="makeDate(item.start_date_year, item.start_date_month, item.start_date_day)"
                />
              </td>
              <td v-if="!showResultMap">
                <span
                  v-html="makeDate(item.end_date_year, item.end_date_month, item.end_date_day)"
                />
              </td>
            <td v-if="!showResultMap">
              <span> -no country data- </span>
            </td>
            <td v-if="!showResultMap">
              <span> -no state data- </span>
            </td>
            <td>
              <span> -no object count- </span>
            </td>
            <td v-if="!showResultMap">
              <pin-component
                v-if="item.id"
                :object-id="item.id"
                :type="item.base_class"/>
            </td>
            <td v-if="!showResultMap">
              <span data-icon="trash" @click="delistCE(index)"/>
            </td>
            <td><input type="checkbox" :value="item.id" v-model="selected"/></td>
            <td/>
          </tr>
          </tbody>
        </table>
      </div>
      <l-map
        class="separate-right"
        v-if="showResultMap"
        height="512px"
        width="100%"
        :zoom="zoomForMap"
        :geojson="featuresList"
        ref="leaflet"
        @geoJsonLayerCreated="shapes.push(JSON.stringify($event));"
        :light-this-feature="lightMapFeatures"
        @geoJsonLayersEdited="editedShape($event)"
        @shapeCreated="inspectLayer"
        @highlightRow="highlightRow=$event"
        @restoreRow="highlightRow=0"
        :draw-controls="true"
      />
    </div>
 </div>
</template>

<script>
  import SmartSelector from 'components/switch.vue'
  import ceFilter from './ce_filter.vue'
  import ceByArea from './ce_by_area.vue'
  import ceByShape from './ce_by_shape.vue'
  import ceTag from './ce_tag.vue'
  import AnnotationLogic from 'browse_annotations/components/annotation_logic'
  import PinComponent from "components/pin.vue"
  import Spinner from 'components/spinner'
  import lMap from './leafletMap.vue'

  export default {
    components: {
      SmartSelector,
      ceFilter,
      ceByArea,
      ceByShape,
      ceTag,
      AnnotationLogic,
      PinComponent,
      lMap,
      Spinner,
    },
    computed: {
      zoomForMap() {
        return this.showResultList ? 2 : 1
      },
      showList() {
        return this.list
      }
    },
    data() {
      return {
        list: {},
        tabs: [],
        moreOptions: ['Filter', 'Named Area Search', 'Drawn Area Search', 'Tag'],
        view: undefined,
        collectingEventList: [],
        featuresList: [],
        selected: [],
        isSelectAll: false,
        annotation_logic: 'append',
        highlightRow: undefined,
        restoreRow: undefined,
        lightRow: undefined,
        dimRow: undefined,
        shapes: [],
        lightMapFeatures: 0,
        isLoading: false,
        showResultList: true,
        showResultMap: false,
      }
    },
    watch: {
      isSelectAll(newVal) {
        if (!newVal) {
          this.selected = []
        }
      },
      showResultList() {
        this.$nextTick(() => {
          this.$refs.leaflet.mapObject.invalidateSize()
        })
      }
    },
    methods: {
      compileList(newColEvList) {
        if (this.annotation_logic == 'append') {
          if (this.collectingEventList.length) {
            let i;  // don't add duplicates
            let extantEvents = this.collectingEventList.map(ce => {
              return ce.id
            });
            for (i = newColEvList.length - 1; i > -1; i--) {
              if (extantEvents.includes(newColEvList[i].id)) {
                this.$delete(newColEvList, i)
              }
            }
            this.collectingEventList = newColEvList.concat(this.collectingEventList);
          } else {
            this.collectingEventList = newColEvList;
            this.selected = [];
          }
        } else {
          this.collectingEventList = newColEvList;
          this.selected = [];
        }
        this.getGeoreferences();
      },
      resetList() {
        this.collectingEventList = [];
      },
      showObject(id) {
        window.open(`/collecting_events/` + id, '_blank');
      },
      delistCE(index) {
        let ce_id = this.collectingEventList[index].id;
        for (let i = this.featuresList.length - 1; i > -1; i--) {
          if (this.featuresList[i].properties.collecting_event_id == ce_id) {
            this.$delete(this.featuresList, i);
          }
        }
        this.$delete(this.collectingEventList, index);
      },
      keepSelected() {  //loop down from top to avoid re-indexing issues
        for (let i = this.collectingEventList.length - 1; i > -1; i--) {
          if (!this.selected.includes(this.collectingEventList[i].id)) {
            this.delistCE(i)
          }
        }
      },
      selectAllList() {
        this.selected = [];               // toggle on state of header checkbox (??  !!)
        /*if (this.isSelectAll)*/ {
          for (let i = this.collectingEventList.length - 1; i > -1; i--) {
            if (!this.selected.includes(this.collectingEventList[i].id)) {
              this.selected.push(this.collectingEventList[i].id);
            }
          }
        }
        // this.isSelectAll = ! this.isSelectAll;
      },
      deselectAllList() {
        this.selected = []
      },
      removeAllList() {
        for (let i = this.collectingEventList.length - 1; i > -1; i--) {
           this.delistCE(i)
        }
      },
      processList() {
        this.getGeoreferences()
      },
      getGeoreferences() {
        let ce_ids = [];      // find the georeferences for these collecting_events
        this.collectingEventList.forEach(ce => {
          ce_ids.push(ce.id)
        });
        if (ce_ids.length) {                // if the list has contents
          let cycles = (ce_ids.length / 30);  // each item is about 30 characters, make each cycle less than 2000 chars
          let FeatureCollection = {
            "type": "FeatureCollection",
            "features": []
          };
          let that = this;
          let thisSlice = 0;
          let endSlice;
          let finalSlice = ce_ids.length;
          this.newFeatures = [];
          let promises = [];
          for (let i = 0; i < cycles; i++) {
            endSlice = thisSlice + 30;
            if ((thisSlice + 30) > finalSlice) {
              endSlice = finalSlice + 1
            }
            let params = {
              collecting_event_ids: ce_ids.slice(thisSlice, endSlice)
            };
            promises.push(this.makePromise(params));
            thisSlice += 30;
          }
          Promise.all(promises).then(featuresArrays => {
            // if (searchShape) {FeatureCollection.features.push(searchShape)}
            featuresArrays.forEach(f => {
              FeatureCollection.features = FeatureCollection.features.concat(f)
            });
            that.featuresList = that.featuresList.concat(FeatureCollection.features);
            this.$emit('featuresList', this.featuresList);
          });
          this.isLoading = false;
        } else {
          this.isLoading = false;
        }
      },
      makePromise(params) {
        return new Promise((resolve, reject) => {
          this.$http.get('/georeferences.json', {params: params}).then(response => {
            // put these geometries on the map as features
            let newFeatures = response.body.map(georeference => {
              georeference.geo_json.properties["collecting_event_id"] = georeference.collecting_event_id;
              return georeference.geo_json
            });
            resolve(newFeatures);    // resolves to array of features
          })
        })
      },
      editedShape() {

      },
      inspectLayer() {

      },
      setHighlight() {

      },
      clearHighlight() {

      },
      setHighlightProperty(id) {
        // find the right features by collecting_event_id
        this.lightMapFeatures = id;
      },
      clearHighlightProperty(id) {
        // find the right feature by collecting_event_id
        this.featuresList.forEach((feature, index) => {
          if (feature.properties.collecting_event_id == id) {
            delete (feature.properties.highlight);
            this.$set(this.featuresList, index, feature)
          }
        });
      },
      makeDate(year, month, day) {
        year = year ? year : '';
        month = month ? month : '';
        day = day ? day : '';
        let date = year.toString() + '-' + month.toString() + '-' + day.toString();
        if (date == '--') return '';
        return date
      }
    },
    mounted: function () {
      this.$http.get('/collecting_events/select_options').then(response => {
        this.tabs = Object.keys(response.body);
        this.list = response.body;
        if (this.tabs.length) {
          this.view = this.tabs[0]
        }
      })
    },
  }
</script>
<style scoped>
  .my-column {
    width: 40%;
    min-width: 40%;
    max-width: 40%;
  }

  .ce-row {
    background-color: #BBDDBB
  }

  tr:hover {
    background-color: #BBDDBB
  }
</style>