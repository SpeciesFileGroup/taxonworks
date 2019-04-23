<template>
  <div class="panel content">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"
    />
    <div v-show="showFilter"> 
      <smart-selector
        class="separate-bottom"
        :options="tabs"
        name="collecting_event"
        :add-option="moreOptions"
        v-model="view" 
      />
      <template>
        <div v-if="view === TABS.attribute">
          <ce-filter @collectingEventList="compileList($event)" />
        </div>
        <div v-else-if="view === TABS.namedAreaSearch">
          <ce-by-area @collectingEventList="compileList($event)" />
        </div>
        <div v-else-if="view === TABS.drawAreaSearch">
          <ce-by-shape
            @collectingEventList="compileList($event)"
            @searchShape="addSearchShape"
            ref="cebyshape"
          />
        </div>
        <div v-else-if="view === TABS.tag">
          <ce-tag @collectingEventList="compileList($event)" />
        </div>
        <smart-list
          v-if="!Object.values(TABS).includes(view)"
          :list="showList[view]"
          :view="view"
          :list-selected="collectingEventList"/>
      </template>
    </div>
    <div>
      <div class="separate-top">
        <h2>Collecting Events</h2>
        <div class="flex-separate separate-top">
          <div>
            <span v-if="collectingEventList.length">
              {{ collectingEventList.length }} results found.
            </span>
          </div>
          <div>
            <input
              type="button"
              class="button button-default normal-input"
              @click="selectAllList"
              value="Select all"
            >
            <input
              type="button"
              class="button button-default normal-input"
              @click="deselectAllList"
              value="Select none"
            >
            <input
              type="button"
              class="button button-default normal-input"
              @click="keepSelected"
              value="Remove unselected"
            >
            <input
              type="button"
              class="button button-default normal-input"
              @click="removeAllList"
              value="Remove all"
            >
          </div>
        </div>
      </div>
    </div>
    <div class="flexbox">
      <div
        class="first-column"
        v-if="showResultList"
      >
        <table class="full_width">
          <thead>
            <tr>
              <th>Verbatim locality</th>
              <template v-if="!showResultMap">
                <th>Date start</th>
                <th>Level 1</th>
                <th>Level 2</th>
                <th>Level 3</th>
              </template>
              <th>Total objects</th>
              <th>Options</th>
              <th> Select </th>
            </tr>
          </thead>
          <transition-group
            name="list-complete"
            tag="tbody"
            @mouseout.native="lightRow = 0">
            <tr
              v-for="(item, index) in collectingEventList"
              :key="item.id"
              class="list-complete-item"
              :class="{'ce-row': lightRow == item.id}"
              @mouseover="lightRow = item.id"
            >
              <td class="my-column">
                <span
                  v-html="item.id + ' ' + item.verbatim_locality"
                  @click="showObject(item.id)"
                />
              </td>
              <template v-if="!showResultMap">
                <td>
                  <span v-html="makeDate(item.start_date_year, item.start_date_month, item.start_date_day)"/>
                </td>
                <td>{{ item.cached_level0_geographic_name }}</td>
                <td>{{ item.cached_level1_geographic_name }}</td>
                <td>{{ item.cached_level2_geographic_name }}</td>
              </template>
              <td>
                <span> -no object count- </span>
              </td>
              <td class="horizontal-left-content">
                <radial-annotator :global-id="item.global_id" />
                <object-annotator :global-id="item.global_id" />
                <pin-component
                  v-if="item.id"
                  :object-id="item.id"
                  :type="item.base_class" 
                />
                <span
                  class="circle-button btn-delete button-default"
                  @click="delistCE(index)"
                />
              </td>
              <td>
                <input
                  type="checkbox"
                  :value="item.id"
                  v-model="selected"
                >
              </td>
            </tr>
          </transition-group>
        </table>
      </div>
      <div
        v-if="showResultMap"
        :class="{ 'separate-left': showResultList }"
        class="separate-map">
        <l-map
          class="separate-right"
          height="512px"
          width="100%"
          :zoom="zoomForMap"
          :geojson="featuresList"
          :light-this-feature="lightRow"
          @highlightRow="lightRow = $event"
          @restoreRow="lightRow = undefined"
          :draw-controls="false"
          :resize="true"
        />
      </div>
    </div>
  </div>
</template>

<script>

  import SmartSelector from 'components/switch.vue'
  import SmartList from './smartList.vue'
  import ceFilter from './ce_filter.vue'
  import ceByArea from './ce_by_area.vue'
  import ceByShape from './ce_by_shape.vue'
  import ceTag from './ce_tag.vue'
  import PinComponent from "components/pin.vue"
  import Spinner from 'components/spinner'
  import lMap from './leafletMap.vue'
  import RadialAnnotator from 'components/annotator/annotator'
  import ObjectAnnotator from 'components/radial_object/radialObject'

  const TABS = {
    attribute: 'By attribute',
    namedAreaSearch: 'By geographic area',
    drawAreaSearch: 'Draw area search',
    tag: 'tag'
  }

  export default {
    components: {
      SmartSelector,
      SmartList,
      ceFilter,
      ceByArea,
      ceByShape,
      ceTag,
      PinComponent,
      lMap,
      Spinner,
      RadialAnnotator,
      ObjectAnnotator,
    },
    props: {
      showResultList: {
        type: Boolean,
        default: true
      },
      showResultMap: {
        type: Boolean,
        default: false
      },
      showFilter: {
        type: Boolean,
        default: true
      },
      append: {
        type: Boolean,
        default: false
      }
    },
    computed: {
      zoomForMap() {
        return this.showResultList ? 2 : 1
      },
      widthForMap() {
        return this.showResultList ? '100%' : '75%'
      },
      showList() {
        return this.list
      },
      TABS() {
        return TABS
      }
    },
    data() {
      return {
        list: {},
        tabs: [],
        moreOptions: Object.values(TABS),
        view: undefined,
        collectingEventList: [],
        featuresList: [],
        selected: [],
        lightRow: undefined,
        shapes: [],
        lightMapFeatures: 0,
        isLoading: false,
      }
    },
    watch: {
      shapes(newVal) {
        this.featuresList.push(newVal)
      }
    },
    methods: {
      compileList(newColEvList) {
        if (this.append) {
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
      resetPage() {
        this.removeAllList();  // clear the collecting event list
        this.$refs.cebyshape.clearTheMap();
        for (let i = this.featuresList.length - 1; i > -1; i--) {
          this.$delete(this.featuresList, i);
        }
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
        
        for (let i = this.collectingEventList.length - 1; i > -1; i--) {
          if (!this.selected.includes(this.collectingEventList[i].id)) {
            this.selected.push(this.collectingEventList[i].id);
          }
        }
      },
      deselectAllList() {
        this.selected = []
      },
      removeAllList() {
        for (let i = this.collectingEventList.length - 1; i > -1; i--) {
           this.delistCE(i)
        }
      },
      getGeoreferences() {
        let ce_ids = [];      // find the georeferences for these collecting_events
        this.collectingEventList.forEach(ce => {
          ce_ids.push(ce.id)
        });
        if(!this.append) {
          this.featuresList = [].concat(this.shapes)
        }
        if (ce_ids.length) {                // if the list has contents
          let cycles = (ce_ids.length / 30);  // each item is about 30 characters, make each cycle less than 2000 chars
          let FeatureCollection = {
            "type": "FeatureCollection",
            "features": []
          };
          let that = this;
          let thisCycle = 0;
          let endCycle;
          let finalCycle = ce_ids.length;
          this.newFeatures = [];
          let promises = [];
          for (let i = 0; i < cycles; i++) {
            endCycle = thisCycle + 30;
            if ((thisCycle + 30) > finalCycle) {
              endCycle = finalCycle + 1
            }
            let params = {
              collecting_event_ids: ce_ids.slice(thisCycle, endCycle)
            };
            promises.push(this.makePromise(params));
            thisCycle += 30;
          }
          Promise.all(promises).then(featuresArrays => {
            featuresArrays.forEach(f => {
              FeatureCollection.features = FeatureCollection.features.concat(f)
            });
            that.featuresList = that.featuresList.concat(FeatureCollection.features);
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
      addSearchShape(shape) {
        this.shapes = shape;
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

  .separate-map {
    padding-top: 1em;
  }
</style>