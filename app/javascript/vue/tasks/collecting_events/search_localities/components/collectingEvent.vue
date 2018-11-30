
<template>
  <div>
    <h3>Collecting event</h3>
    <!--<autocomplete-->
      <!--url="/collecting_events/autocomplete"-->
      <!--min="2"-->
      <!--label="label_html"-->
      <!--placeholder="Select a place name"-->
      <!--:autofocus="true"-->
      <!--@getItem="sendCollectingEvent"-->
      <!--display="label"-->
      <!--param="term"/>-->
    <smart-selector
      :options="tabs"
      name="collecting_event"
      :add-option="moreOptions"
      v-model="view"/>
    <template>
      <div
        v-if="view === 'Search'"
        class="horizontal-left-content">
        <autocomplete
          class="separate-bottom"
          url="/geographic_areas/autocomplete"
          min="2"
          ref="autocomplete"
          param="term"
          placeholder="Select a geographic area"
          label="label"
          @getItem="sendGeographic($event)"
          :autofocus="true"
          :clear-after="true"/>
      </div>
      <div v-else-if="view === 'Tag'">
        <!--class="horizontal-left-content">-->
        <!--<autocomplete-->
          <!--class="separate-bottom"-->
          <!--url="/controlled_vocabulary_terms/autocomplete"-->
          <!--min="2"-->
          <!--ref="autocomplete"-->
          <!--:add-params="{'of_type[]' : 'Keyword'}"-->
          <!--param="term"-->
          <!--placeholder="Select a tag"-->
          <!--label="label"-->
          <!--@getItem="sendTag($event)"-->
          <!--:autofocus="true"-->
          <!--:clear-after="true"/>-->
        <ce-tag/>
      </div>
      <div v-else-if="view === 'Filter'">
        <ce-filter/>
      </div>
      <template v-else>
        <button
          v-for="item in showList[view]"
          :key="item.id"
          type="button"
          class="button normal-input button-submit biocuration-toggle-button"
          @click="createTaxonCite(item)"
          v-html="item.cached"/>
      </template>
    </template>
  </div>
</template>

<script>
  import SmartSelector from 'components/switch.vue'
  import Autocomplete from 'components/autocomplete.vue'
  import ceFilter from './ce_filter.vue'
  import ceTag from './ce_tag.vue'

  export default {
    components: {
      SmartSelector,
      Autocomplete,
      ceFilter,
      ceTag
    },
    data() {
      return {
        list: {},
        tabs: [],
        moreOptions: ['Filter', 'Search', 'Tag'],
        view: undefined
      }
    },
    methods: {
      sendCollectingEvent(item) {
        // this.selected=item.id;
        this.$emit('itemid', item.id)
      },
      sendGeographic(item) {
        this.selected = '';
        this.$emit('select', item.id)
      },
      sendTag(item) {
        this.selected = '';
        this.$emit('select', item.id)
      },
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
    },
  }
</script>
