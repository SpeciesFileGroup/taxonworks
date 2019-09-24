<template>
  <div>
    <button
      @click="onModal"
      type="button"
      :disabled="!collectingEvent.id"
      class="button normal-input button-default">
      Georeferences
      <template v-if="count > 0">
        ({{ count }})
      </template>
    </button>
    <modal-component
      class="modal-georeferences"
      @close="onModal"
      v-if="show">
      <h3 slot="header">Georeferences</h3>
      <div slot="body">
        <georeferences
          @onGeoreferences="count = $event.length"
          :zoom="5"
          :lat="lat"
          :lng="lng"
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
    }
  },
  data () {
    return {
      show: false,
      count: 0
    }
  },
  methods: {
    onModal () {
      this.show = !this.show
      this.$emit('onModal', this.show)
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
