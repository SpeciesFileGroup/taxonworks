<template>
  <div>
    <button
      @click="openModal"
      type="button"
      :disabled="!collectingEvent.id"
      class="button normal-input button-default margin-small-right">
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
      <template #header>
        <h3>Georeferences</h3>
      </template>
      <template #body>
        <georeferences-component
          :show="show"
          v-model="georeferences"
          ref="georeference"
          @onGeoreferences="runSoftValidations"
          :zoom="5"
          :lat="lat"
          :lng="lng"
          :geographic-area="geographicArea"
          :geolocation-uncertainty="geolocationUncertainty"
          :verbatim-lat="collectingEvent.verbatim_latitude"
          :verbatim-lng="collectingEvent.verbatim_longitude"
          :collecting-event-id="collectingEvent.id"/>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import GeoreferencesComponent from 'components/georeferences/georeferences'
import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'
import { ActionNames } from '../../../../store/actions/actions.js'

import { truncateDecimal } from 'helpers/math.js'
import convertDMS from 'helpers/parseDMS.js'

export default {
  components: {
    ModalComponent,
    GeoreferencesComponent
  },

  emits: ['onModal'],

  computed: {
    collectingEvent () {
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
      return this.verbatimGeoreferenceAlreadyCreated?.geo_json?.properties?.radius
    },

    geographicArea () {
      return this.$store.getters[GetterNames.GetGeographicArea]?.shape
    },

    verbatimGeoreferenceAlreadyCreated () {
      return this.georeferences.find(item => item.type === 'Georeference::VerbatimData')
    },

    georeferences: {
      get () {
        return this.$store.getters[GetterNames.GetGeoreferences]
      },
      set (value) {
        this.$store.commit(MutationNames.SetGeoreferences, value)
      }
    },

    count () {
      return this.georeferences.length
    }
  },

  data () {
    return {
      show: false
    }
  },

  methods: {
    openModal () {
      this.show = true
      this.$emit('onModal', this.show)
    },

    closeModal () {
      this.show = false
      this.$emit('onModal', this.show)
    },

    runSoftValidations () {
      this.$store.dispatch(ActionNames.LoadSoftValidations)
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
