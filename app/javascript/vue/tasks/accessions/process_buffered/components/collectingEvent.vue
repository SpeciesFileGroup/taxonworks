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
          model="geographic_areas"
          klass="CollectingEvent"
          pin-section="GeographicAreas"
          pin-type="GeographicArea"
          @selected="setGeographicArea"/>
          <div
            v-if="geographicArea"
            class="horizontal-left-content">
            <span class="margin-small-right">{{ geographicArea.name }}</span>
            <span
              @click="removeGeo"
              class="circle-button btn-undo button-default"/>
          </div>
      </fieldset>
    </div>
    <template v-for="field in verbatimFields">
      <verbatim-field
        :key="field"
        v-if="field != 'verbatim_locality'"
        :field="field"/>
    </template>
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

import { GetGeographicArea } from '../request/resource'
import SmartSelector from 'components/smartSelector'
import Autocomplete from 'components/autocomplete'
import VerbatimField from './verbatimField'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

import extractDate from '../helpers/extractDate'

export default {
  components: {
    Autocomplete,
    SmartSelector,
    VerbatimField
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
    },
    verbatimFields () {
      return Object.keys(this.collectingEvent).filter(key => { return key.startsWith('verbatim') })
    }
  },
  data () {
    return {
      geographicArea: undefined
    }
  },
  watch: {
    collectingEvent: {
      handler (newVal, oldVal) {
        if (newVal.id !== oldVal.id && newVal.geographic_area_id) {
          GetGeographicArea(newVal.geographic_area_id).then(response => {
            this.geographicArea = response.body
          })
        }
      },
      deep: true
    }
  },
  methods: {
    setGeographicArea (geoArea) {
      this.collectingEvent.geographic_area_id = geoArea.id
      this.geographicArea = geoArea
    },
    setEndExtractDate () {
      const date = this.getExtractDate.split('/')
      this.collectingEvent.end_date_year = date[0]
      this.collectingEvent.end_date_month = date[1]
      this.collectingEvent.end_date_day = date[2]
    },
    setStartExtractDate () {
      const date = this.getExtractDate.split('/')
      this.collectingEvent.start_date_year = date[0]
      this.collectingEvent.start_date_month = date[1]
      this.collectingEvent.start_date_day = date[2]
    },
    removeGeo () {
      this.geographicArea = undefined
      this.collectingEvent.geographic_area_id = null
    }
  }
}
</script>

<style scoped>
  .date-field {
    width: 50px;
  }
</style>