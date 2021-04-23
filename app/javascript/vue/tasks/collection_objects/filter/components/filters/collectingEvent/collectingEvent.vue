<template>
  <div>
    <h3>Collecting Event</h3>
    <h4>Date range</h4>
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
      <h4>Select collecting events</h4>
      <smart-selector
        model="collecting_events"
        klass="CollectionObject"
        pin-section="CollectingEvents"
        pin-type="CollectingEvent"
        @selected="addCe"/>
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
    <add-field
      ref="fields"
      :list="cEvent.fields"
      @fields="cEvent.fields = $event"/>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'
import SmartSelector from 'components/smartSelector'
import AddField from './addFields'
import { GetCollectingEvents } from '../../../request/resources'

export default {
  components: {
    SmartSelector,
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
  watch: {
    cEvent: {
      handler (newVal) {
        if (!newVal.fields) {
          this.$refs.fields.cleanList()
        }
      },
      deep: true
    }
  },
  data () {
    return {
      collectingEvents: []
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (urlParams.collecting_event_ids) {
      urlParams.collecting_event_ids.forEach(id => {
        GetCollectingEvents(id).then(response => {
          this.addCe(response.body)
        })
      })
    }
    this.cEvent.start_date = urlParams.start_date
    this.cEvent.end_date = urlParams.end_date
    this.cEvent.partial_overlap_dates = urlParams.partial_overlap_dates
  },
  methods: {
    addCe (ce) {
      if (this.cEvent.collecting_event_ids.includes(ce.id)) return
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
