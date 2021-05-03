<template>
  <div>
    <button
      @click="openModal"
      type="button"
      :disabled="!collectingEvent.id"
      class="button normal-input button-default">
      Georeferences
      <template v-if="count > 0">
        ({{ count }})
      </template>
    </button>
    <button
      v-if="!verbatimGeoreferenceAlreadyCreated"
      type="button"
      class="button normal-input button-submit"
      :disabled="!collectingEvent.id || !existCoordinates"
      @click="$refs.georeference.createVerbatimShape()">
      Create georeference from verbatim
    </button>
    <template v-if="verbatimGeoreferenceAlreadyCreated">
      <span>Lat: {{ georeferenceVerbatimLatitude }}, Long: {{ georeferenceVerbatimLongitude }}<span v-if="georeferenceVerbatimRadiusError">, Radius error: {{ georeferenceVerbatimRadiusError }}</span></span>
    </template>
    <modal-component
      class="modal-georeferences"
      @close="closeModal"
      v-show="show">
      <h3 slot="header">Georeferences</h3>
      <div slot="body">
        <georeferences
          :show="show"
          ref="georeference"
          @onGeoreferences="georeferences = $event"
          :zoom="5"
          :lat="lat"
          :lng="lng"
          :geographic-area="geographicArea"
          :geolocation-uncertainty="geolocationUncertainty"
          :verbatim-lat="collectingEvent.verbatim_latitude"
          :verbatim-lng="collectingEvent.verbatim_longitude"
          :collecting-event-id="collectingEvent.id"/>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import Georeferences from 'components/georeferences/georeferences'
import { GetterNames } from '../../../../store/getters/getters.js'
import { ActionNames } from '../../../../store/actions/actions'

import { truncateDecimal } from 'helpers/math.js'
import convertDMS from 'helpers/parseDMS.js'

export default {
  components: {
    ModalComponent,
    Georeferences
  },
  computed: {
    collectingEvent() {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    },
    lat () {
      return parseFloat(this.collectingEvent.verbatim_latitude)
    },
    lng () {
      return parseFloat(this.collectingEvent.verbatim_longitude)
    },
    existCoordinates () {
      const lat = this.collectingEvent.verbatim_latitude
      const lng = this.collectingEvent.verbatim_longitude

      return convertDMS(lat) && convertDMS(lng)
    },
    geolocationUncertainty () {
      return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_geolocation_uncertainty
    },
    georeferenceVerbatimLatitude () {
      return this.verbatimGeoreferenceAlreadyCreated ? truncateDecimal(this.verbatimGeoreferenceAlreadyCreated.geo_json.geometry.coordinates[1], 6) : undefined
    },
    georeferenceVerbatimLongitude () {
      return this.verbatimGeoreferenceAlreadyCreated ? truncateDecimal(this.verbatimGeoreferenceAlreadyCreated.geo_json.geometry.coordinates[0], 6) : undefined
    },
    georeferenceVerbatimRadiusError () {
      return this.verbatimGeoreferenceAlreadyCreated ? this.verbatimGeoreferenceAlreadyCreated.geo_json.properties.radius : undefined
    },
    geographicArea () {
      if(!this.$store.getters[GetterNames.GetGeographicArea]) return
      return this.$store.getters[GetterNames.GetGeographicArea]['shape']
    },
    verbatimGeoreferenceAlreadyCreated () {
      return this.georeferences.find(item => { return item.type === 'Georeference::VerbatimData' })
    },
    count () {
      return this.georeferences.length
    }
  },
  watch: {
    collectingEvent: {
      handler (newVal, oldVal) {
        if(!newVal.id) {
          this.georeferences = []
        }
      },
      deep: true,
      immediate: true
    }
  },
  data () {
    return {
      show: false,
      georeferences: []
    }
  },
  methods: {
    openModal () {
      this.$store.dispatch(ActionNames.SaveCollectionEvent, this.collectingEvent).then(() => {
        this.show = true
        this.$emit('onModal', this.show)
      })
    },
    closeModal () {
      this.$store.dispatch(ActionNames.SaveCollectionEvent, this.collectingEvent).then(() => {
        this.show = false
        this.$emit('onModal', this.show)
      })
    }
  }
}
</script>

<style lang="scss">
  .modal-georeferences {
    .modal-container {
      width: 500px;
    }
  }
</style>
