<template>
  <div>
    <div class="field">
      <label>Verbatim locality</label>
      <autocomplete
        url="/collecting_events/autocomplete_collecting_event_verbatim_locality"
        param="term"
        v-model="collectingEvent.verbatim_locality"
        label="label"
        @getItem="collectingEvent.verbatim_locality = $event.value"
      />
    </div>
    <div class="field">
      <fieldset>
        <legend>Geographic area</legend>
        <smart-selector
          class="separate-bottom"
          :options="options"
          v-model="view"/>
        <autocomplete
          v-if="view == 'search'"
          url="/geographic_areas/autocomplete"
          param="term"
          label="label_html"
          placeholder="Search a geographic area"
          display="label"
          @getItem="collectingEvent.geographic_area_id = $event.id"
        />
        <ul
          v-else
          class="no_bullets">
          <li
            v-for="item in smartList[view]"
            :key="item.id">
            <label>
              <input type="radio">
              <span v-html="item.name"></span>
            </label>
          </li>
        </ul>
      </fieldset>
    </div>
    <div class="field">
      <label>Verbatim lat</label>
      <br>
      <input
        type="text"
        v-model="collectingEvent.verbatim_latitude">
    </div>
    <div class="field">
      <label>Verbatim long</label>
      <br>
      <input
        type="text"
        v-model="collectingEvent.verbatim_longitude">
    </div>
    <div>
      <span>Start date</span>
      <div class="horizontal-left-content">
        <div>
          <label>Year</label>
          <br>
          <input
            type="text"
            v-model="collectingEvent.start_date_year">
        </div>
        <div>
          <label>Month</label>
          <br>
          <input
            type="text"
            v-model="collectingEvent.start_date_month">
        </div>
        <div>
          <label>Day</label>
          <br>
          <input
            type="text"
            v-model="collectingEvent.start_date_day">
        </div>
      </div>
    </div>
    <div>
      <span>End date</span>
      <div class="horizontal-left-content">
        <div>
          <label>Year</label>
          <br>
          <input
            type="text"
            v-model="collectingEvent.end_date_year">
        </div>
        <div>
          <label>Month</label>
          <br>
          <input
            type="text"
            v-model="collectingEvent.end_date_month">
        </div>
        <div>
          <label>Day</label>
          <br>
          <input
            type="text"
            v-model="collectingEvent.end_date_day">
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import { GetCollectingEvent, GetGeographicSmartSelector } from '../request/resource'
import Autocomplete from 'components/autocomplete'
import SmartSelector from 'components/switch'

export default {
  components: {
    Autocomplete,
    SmartSelector
  },
  props: {
    collectionObject: {
      type: Object,
      default: undefined
    }
  },
  data () {
    return {
      collectingEvent: {
        verbatim_locality: undefined,
        geographic_area_id: undefined,
        verbatim_latitude: undefined,
        verbatim_longitude: undefined,
        start_date_day: undefined,
        start_date_month: undefined, 
        start_date_year: undefined,
        end_date_day: undefined,
        end_date_month: undefined,
        end_date_year: undefined
      },
      smartList: undefined,
      options: [],
      view: 'search'
    }
  },
  watch: {
    collectionObject: {
      handler (newVal) {
        if (newVal && newVal.collecting_event_id) {
          GetCollectingEvent(newVal.collecting_event_id).then(response => {
            this.collectingEvent = response.body
          })
        }
      },
      immediate: true
    }
  },
  mounted () {
    GetGeographicSmartSelector().then(response => {
      this.options = Object.keys(response.body)
      this.options.push('search')
      this.smartList = response.body
    })
  },
  methods: {
  }
}
</script>