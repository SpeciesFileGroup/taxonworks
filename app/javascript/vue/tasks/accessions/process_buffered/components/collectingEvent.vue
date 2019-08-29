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
            class="date-field separate-right"
            type="text"
            v-model="collectingEvent.start_date_year">
        </div>
        <div>
          <label>Month</label>
          <br>
          <input
            class="date-field separate-right"
            type="text"
            v-model="collectingEvent.start_date_month">
        </div>
        <div>
          <label>Day</label>
          <br>
          <input
            class="date-field"
            type="text"
            v-model="collectingEvent.start_date_day">
        </div>
        <div class="separate-left">
          <label>&nbsp;</label>
          <br>
          <button
            v-if="getExtractDate"
            type="button"
            class="button normal-input button-default"
            @click="setStartExtractDate">
            Use {{ getExtractDate }}
          </button>
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
            class="date-field separate-right"
            type="text"
            v-model="collectingEvent.end_date_year">
        </div>
        <div>
          <label>Month</label>
          <br>
          <input
            class="date-field separate-right"
            type="text"
            v-model="collectingEvent.end_date_month">
        </div>
        <div>
          <label>Day</label>
          <br>
          <input
            class="date-field"
            type="text"
            v-model="collectingEvent.end_date_day">
        </div>
        <div class="separate-left">
          <label>&nbsp;</label>
          <br>
          <button
            v-if="getExtractDate"
            type="button"
            class="button normal-input button-default"
            @click="setEndExtractDate">
            Use {{ getExtractDate }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import { GetGeographicSmartSelector, GetGeographicArea } from '../request/resource'
import Autocomplete from 'components/autocomplete'
import SmartSelector from 'components/switch'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

import extractDate from '../helpers/extractDate'

export default {
  components: {
    Autocomplete,
    SmartSelector
  },
  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },
    getSelection () {
      return this.$store.getters[GetterNames.GetSelection]
    },
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    },
    getExtractDate () {
      return extractDate(this.collectionObject.buffered_collecting_event)
    }
  },
  data () {
    return {
      smartList: undefined,
      options: [],
      view: 'search',
      selectedGeographicAreaLabel: undefined
    }
  },
  watch: {
    getSelection (newVal) {
      if (newVal.length) {
        this.collectingEvent.verbatim_locality = newVal
      }
    },
    collectingEvent: {
      handler (newVal, oldVal) {
        if (newVal.geographic_area_id && newVal !== oldVal) {
          GetGeographicArea(newVal.geographic_area_id).then(response => {
            this.selectedGeographicAreaLabel = response.body.name
          })
        }
      },
      deep: true
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
    setEndExtractDate() {
      let date = this.getExtractDate.split('/')
      this.collectingEvent.end_date_year = date[0]
      this.collectingEvent.end_date_month = date[1]
      this.collectingEvent.end_date_day = date[2]
    },
    setStartExtractDate() {
      let date = this.getExtractDate.split('/')
      this.collectingEvent.start_date_year = date[0]
      this.collectingEvent.start_date_month = date[1]
      this.collectingEvent.start_date_day = date[2]
    }
  }
}
</script>

<style scoped>
  .date-field {
    width: 50px;
  }
</style>