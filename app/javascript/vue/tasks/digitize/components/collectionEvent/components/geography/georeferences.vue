<template>
  <div>
    <button
      @click="show = !show"
      type="button"
      :disabled="!collectingEvent.id"
      class="button normal-input button-default">
      Georeferences
    </button>
    <modal-component
      class="modal-georeferences"
      @close="show = false"
      v-if="show">
      <h3 slot="header">Georeferences</h3>
      <div slot="body">
        <georeferences
          :zoom="5"
          :lat="lat"
          :lng="lng"
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
  data() {
    return {
      show: false
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
