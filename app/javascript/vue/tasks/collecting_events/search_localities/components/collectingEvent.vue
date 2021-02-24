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
          <ce-filter
            @jsonUrl="$emit('jsonUrl', $event)"
            @collectingEventList="compileList($event)" />
        </div>
        <div v-else-if="view === TABS.namedAreaSearch">
          <ce-by-area
            @jsonUrl="$emit('jsonUrl', $event)"
            @collectingEventList="compileList($event)" />
        </div>
        <div v-else-if="view === TABS.drawAreaSearch">
          <ce-by-shape
            @jsonUrl="$emit('jsonUrl', $event)"
            @collectingEventList="compileList($event)"
            @searchShape="addSearchShape"
            ref="cebyshape"
          />
        </div>
        <div v-else-if="view === TABS.tag">
          <ce-tag
            @jsonUrl="$emit('jsonUrl', $event)"
            @collectingEventList="compileList($event)" />
        </div>
        <smart-list
          v-if="!Object.values(TABS).includes(view)"
          :list="showList[view]"
          :view="view"
          @selected="compileList"
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
            <button
              type="button"
              class="button button-default normal-input"
              @click="selectAllList">
              Select all
            </button>
            <button
              type="button"
              class="button button-default normal-input"
              @click="deselectAllList">
              Select none
            </button>
            <button
              type="button"
              class="button button-default normal-input"
              @click="keepSelected">
              Remove unselected
            </button>
            <csv-button :list="collectingEventList"/>
            <button
              type="button"
              class="button button-default normal-input"
              @click="removeAllList">
              Remove all
            </button>
          </div>
        </div>
      </div>
    </div>
    <div class="flexbox">
      <div
        v-show="showResultList"
      >
        <list-ce 
          :list="collectingEventList"
          :highlight-id="lightRow"
          @mouseover="lightRow = $event.id"
          @mouseout="lightRow = 0"
          @remove="delistCE($event)"
          v-model="selected"
        />
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
  import Spinner from 'components/spinner'
  import lMap from './leafletMap.vue'
  import CsvButton from 'components/csvButton.vue'
  import ListCe from './list.vue'
  import AjaxCall from 'helpers/ajaxCall'

  const TABS = {
    attribute: 'By attribute',
    namedAreaSearch: 'By geographic area',
    drawAreaSearch: 'By drawn area',
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
      lMap,
      Spinner,
      CsvButton,
      ListCe
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
          let concat = newColEvList.concat(this.collectingEventList)
                  
          concat = concat.filter((item, index, self) =>
            index === self.findIndex((i) => (
              i.id === item.id
            ))
          )
          this.collectingEventList = concat
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
        })

        if(!this.append) {
          this.featuresList = [].concat(this.shapes)
        }
        else {
          this.featuresList = this.featuresList.concat(this.shapes)
        }
        if (ce_ids.length) {                // if the list has contents
          let cycles = (ce_ids.length / 30);  // each item is about 30 characters, make each cycle less than 2000 chars
          let FeatureCollection = {
            "type": "FeatureCollection",
            "features": []
          }

          let that = this
          let thisCycle = 0
          let endCycle
          let finalCycle = ce_ids.length
          let promises = []

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
          AjaxCall('get', '/georeferences.json', {params: params}).then(response => {
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
    },
    mounted: function () {
      AjaxCall('get', '/collecting_events/select_options').then(response => {
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
  .separate-map {
    padding-top: 1em;
  }
</style>