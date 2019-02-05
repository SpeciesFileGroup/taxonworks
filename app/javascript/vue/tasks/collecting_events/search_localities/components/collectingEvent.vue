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
      <input
        type="button"
        @click="resetList()"
        value="Reset">
    </template>
    <div>
      <div class="annotation_logic separate-left">
      <h2>Collecting Events</h2>
      <annotation-logic v-model="annotation_logic"/>
      </div>
      <span v-if="collectingEventList.length" v-html="'<br>' + collectingEventList.length + '  results found.'"/>
      <table style="width: 100%">
        <th>Cached</th><th>Verbatim Locality</th><th>Pin</th>
        <th class="remove_area" data-icon="trash" @click="resetList()">All</th>
        <th>Select<input type="checkbox" @click="selectAllList()" v-model="isSelectAll"/>
          All &nbsp; &nbsp; &nbsp; <span class="remove_area" data-icon="trash" @click="keepSelected()"> unchecked</span></th>
      <tr
        v-for="(item, index) in collectingEventList"
        :key="item.id">
        <td>
          <span style="width: 40%"
          v-html="item.id + ' ' + item.cached"
          @click="showObject(item.id)"
          />
        </td>
        <td>
          <span style="width: 40%" v-html="item.verbatim_locality" />
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
        isSelectAll: false,
        annotation_logic: 'append',
      }
    },
    watch: {
      isSelectAll(newVal) {
        if(!newVal) {
          this.selected = []
        }
      }
    },
    methods: {
      compileList(colEvList) {
        if(this.annotation_logic == 'append') {
          if(this.collectingEventList.length)
          {this.collectingEventList = colEvList.concat(this.collectingEventList);}
          else
          {
            this.collectingEventList = colEvList;
            this.selected = [];
          }
        }
        else {
          this.collectingEventList = colEvList;
          this.selected = [];
        }
      },
      resetList() {
        this.collectingEventList = [];
      },
      showObject(id) {
        window.open(`/collecting_events/` + id, '_blank');
      },
      delistMe(index) {
        this.$delete(this.collectingEventList, index)
      },
      keepSelected() {  //loop down from top to avoid re-indexing issues
        for (let i = this.collectingEventList.length - 1; i > -1 ; i--) {
          if (!this.selected.includes(this.collectingEventList[i].id)) {
            this.delistMe(i)
          }
        }
      },
      selectAllList() {
        this.selected = [];               // toggle on state of header checkbox (??  !!)
        if(this.isSelectAll); {
          for (let i = this.collectingEventList.length - 1; i > -1; i--) {
            if (!this.selected.includes(this.collectingEventList[i].id)) {
              this.selected.push(this.collectingEventList[i].id);
            }
          }
        }
        // this.isSelectAll = ! this.isSelectAll;
      },
    },
    mounted: function() {
      this.$http.get('/collecting_events/select_options').then(response => {
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
