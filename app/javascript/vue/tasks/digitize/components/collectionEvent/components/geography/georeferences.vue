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
    <i
      v-if="verbatimGeoreferenceAlreadyCreated"
      class="disabled">Verbatim coordinates match</i>
    <modal-component
      class="modal-georeferences"
      @close="closeModal"
      v-show="show">
      <h3 slot="header">Georeferences</h3>
      <div slot="body">
        <georeferences
          :show="show"
          @onGeoreferences="georeferences = $event"
          :zoom="5"
          :lat="lat"
          :lng="lng"
          :geographic-area="geographicArea"
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
import { GetGeographicArea } from '../../../../request/resources'
import { GetterNames } from '../../../../store/getters/getters.js'
import { ActionNames } from '../../../../store/actions/actions'

export default {
  components: {
    ModalComponent,
    Georeferences
  },
  computed: {
    collectingEvent() {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    },
    lat() {
      return parseFloat(this.collectingEvent.verbatim_latitude)
    },
    lng() {
      return parseFloat(this.collectingEvent.verbatim_longitude)
    },
    geographicArea () {
      if(!this.$store.getters[GetterNames.GetGeographicArea]) return
      return this.$store.getters[GetterNames.GetGeographicArea]['shape']
    },
    verbatimGeoreferenceAlreadyCreated () {
      return this.georeferences.find(item => {
        return item.geo_json.geometry.type === 'Point' &&
          Number(item.geo_json.geometry.coordinates[0]) === Number(this.lng) &&
          Number(item.geo_json.geometry.coordinates[1]) === Number(this.lat)
      })
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
