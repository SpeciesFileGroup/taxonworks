<template>
  <div>
    <div>
      <label><b>Start time</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="separate-right">
          <label>Hour</label>
          <input
            type="number"
            min="0"
            max="23"
            v-model="collectingEvent.time_start_hour">
        </div>
        <div class="separate-left separate-right">
          <label>Minute</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="collectingEvent.time_start_minute">
        </div>
        <div class="separate-left">
          <label>Seconds</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="collectingEvent.time_start_second">
        </div>
      </div>
    </div>
    <div>
      <label><b>End time</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="separate-right">
          <label>Hour</label>
          <input
            type="number"
            min="0"
            max="23"
            v-model="collectingEvent.time_end_hour">
        </div>
        <div class="separate-left separate-right">
          <label>Minute</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="collectingEvent.time_end_minute">
        </div>
        <div class="separate-left">
          <label>Seconds</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="collectingEvent.time_end_second">
        </div>
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
