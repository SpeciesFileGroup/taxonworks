<template>
  <div>
    <h2>Collecting Event</h2>
    <h3>Date range</h3>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Start date</label>
        <br>
        <input 
          type="date"
          v-model="cEvent.start_date">
      </div>

      <div class="field">
        <label>End date</label>
        <br>
        <input 
          type="date"
          v-model="cEvent.end_date">
      </div>
    </div>
    <div class="field">
      <label>
        <input
          type="checkbox"
          v-model="cEvent.partial_overlap_dates">
        Allow partial overlaps
      </label>
    </div>
    <div class="field">
      <h3>Select collecting events</h3>
      <smart-selector
        class="separate-bottom"
        :options="tabs"
        v-model="view"
      />
      <ul
        v-if="view !== 'search'"
        class="no_bullets">
        <li 
          v-for="ce in smartLists[view]"
          :key="ce.id"
          v-if="!collectingEvents.map(item => { return item.id }).includes(ce.id)">
          <label>
            <input 
              type="radio"
              @click="addCe(ce)">
            <span v-html="ce.object_tag"/>
          </label>
        </li>
      </ul>
      <div v-else>
        <autocomplete
          url="/collecting_events/autocomplete"
          param="term"
          min="2"
          :clear-after="true"
          label="label_html"
          placeholder="Search a collecting event"
          @getItem="addCe"
        />
      </div>
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(ce, index) in collectingEvents"
          :key="ce.id">
          <span v-html="ce.object_tag"/>
          <span
            class="btn-delete button-circle"
            @click="removeCe(index)"/>
        </li>
      </ul>
    </div>
    <add-field @fields="cEvent.fields = $event"/>
  </div>
</template>

<script>
import { GetCollectingEventSmartSelector } from '../../../request/resources'
import SmartSelector from 'components/switch'
import Autocomplete from 'components/autocomplete'
import AddField from './addFields'

export default {
  components: {
    SmartSelector,
    Autocomplete,
    AddField
  },
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    cEvent: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      partial: false,
      view: undefined,
      tabs: [],
      smartLists: {},
      collectingEvents: []
    }
  },
  mounted () {
    GetCollectingEventSmartSelector().then(response => {
      this.smartLists = response.body
      this.tabs = Object.keys(response.body)
      this.tabs.push('search')
    })
  },
  methods: {
    addCe (ce) {
      if (ce.hasOwnProperty('label_html')) {
        ce.object_tag = ce.label_html
      }
      this.cEvent.collecting_event_ids.push(ce.id)
      this.collectingEvents.push(ce)
    },
    removeCe (index) {
      this.cEvent.collecting_event_ids.splice(index, 1)
      this.collectingEvents.splice(index, 1)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
