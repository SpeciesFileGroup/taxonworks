<template>
  <div>
    <label><b>Elevation</b></label>
    <div class="horizontal-left-content">
      <div class="separate-right">
        <label>Minimum</label>
        <input
          type="text"
          v-model="collectingEvent.minimum_elevation">
      </div>
      <div class="separate-right separate-left">
        <label>Maximum</label>
        <input
          type="text"
          v-model="collectingEvent.maximum_elevation">
      </div>
      <div class="separate-right separate-left">
        <label>Precision</label>
        +/-
        <input
          type="text"
          v-model="collectingEvent.elevation_precision">
      </div>
      <div>
        Unit
        <label>
          <input
            v-model="collectingEvent.units"
            type="radio"
            :value="undefined"
            name="elevation">
          Meters
        </label>
        <label>
          <input
            v-model="collectingEvent.units"
            value="ft"
            type="radio"
            name="elevation">
          Feet
        </label>
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'

export default {
  computed: {
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    }
  }
}
</script>

<style scoped>
  input {
    max-width: 60px;
  }
</style>
