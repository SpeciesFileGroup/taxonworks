<template>
  <div>
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
      <div v-else-if="view === 'Search'">
        <ce-search @collectingEventList="compileList($event)"/>
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
    </template>
    <div>
      <div class="annotation_logic separate-left">
      <h2>Collecting Events</h2>
      <annotation-logic v-model="annotation_logic"/>
      </div>
      <span v-if="collectingEventList.length" v-html="'<br>' + collectingEventList.length + '  results found.'"/>
      <table>
        <th>Cached</th><th>Verbatim Locality</th><th>Pin</th><th class="remove_area" data-icon="trash"/><th>Select</th><th><span class="remove_area" data-icon="trash" @click="keepMe()"> unchecked</span></th>
      <tr
        v-for="(item, index) in collectingEventList"
        :key="item.id">
        <td>
          <span
          v-html="item.id + ' ' + item.cached"
          @click="showObject(item.id)"
          />
        </td>
        <td>
          <span v-html="item.verbatim_locality" />
        </td>
        <td>
          <pin-component
          v-if="item.id"
          :object-id="item.id"
          :type="item.base_class"/>
        </td>
        <td>
          <span class="remove_area" data-icon="trash" @click="delistMe(index)"/>
        </td>
        <td><input type="checkbox" :value="item.id" v-model="selected"/></td>
      </tr>
      </table>
    </div>
  </div>
</template>

<script>
  import SmartSelector from 'components/switch.vue'
  import Autocomplete from 'components/autocomplete.vue'
  import ceFilter from './ce_filter.vue'
  import ceSearch from './ce_search.vue'
  import ceTag from './ce_tag.vue'
  import AnnotationLogic from 'browse_annotations/components/annotation_logic'
  import PinComponent from "components/pin.vue"

  export default {
    components: {
      SmartSelector,
      Autocomplete,
      ceFilter,
      ceSearch,
      ceTag,
      AnnotationLogic,
      PinComponent,
    },
    data() {
      return {
        list: {},
        tabs: [],
        moreOptions: ['Filter', 'Search', 'Tag'],
        view: undefined,
        collectingEventList: [],
        selected: [],
        annotation_logic: 'append',
      }
    },
    methods: {
      sendCollectingEvent(item) {
        // this.selected=item.id;
        this.$emit('itemid', item.id)
      },
      compileList(colEvList) {
        if(this.annotation_logic == 'append') {
          if(this.collectingEventList.length)
          {this.collectingEventList = colEvList.concat(this.collectingEventList);}
          else
          {this.collectingEventList = colEvList;}
        }
        else {
          {
            this.collectingEventList = colEvList;
          }
        }
      },
      showObject(id) {
        window.open(`/collecting_events/` + id, '_blank');
      },
      delistMe(index) {
        this.$delete(this.collectingEventList, index)
      },
      keepMe() {
        let i = 0;
        for (i = 0; i< this.collectingEventList.length; i++) {
          if (!this.selected.includes(this.collectingEventList[i].id)) {
            this.delistMe(i)
          }
        }
      }
    },
    mounted: function() {
      this.$http.get('/collecting_events/select_options').then(response => {
        // this.$delete(response.body, 'quick');    // don't remove quick now that we know what it means
        this.tabs = Object.keys(response.body);
        this.list = response.body;
        if(this.tabs.length) {
          this.view = this.tabs[0]
        }
      })
    },
    computed: {
      showList() {
        return this.list
      }
    }
  }
</script>
