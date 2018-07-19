<template>
  <div>
    <div>
      <label>Start time</label>
      <div class="horizontal-left-content">
        <div class="separate-right">
          <label>Hour</label>
          <input
            type="number"
            min="0"
            max="23"
            v-model="StartHour">
        </div>
        <div class="separate-left separate-right">
          <label>Minute</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="StartMinute">
        </div>
        <div class="separate-left">
          <label>Seconds</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="StartSecond">
        </div>
      </div>
    </div>
    <div>
      <label>End time</label>
      <div class="horizontal-left-content">
        <div class="separate-right">
          <label>Hour</label>
          <input
            type="number"
            min="0"
            max="23"
            v-model="EndHour">
        </div>
        <div class="separate-left separate-right">
          <label>Minute</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="EndMinute">
        </div>
        <div class="separate-left">
          <label>Seconds</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="EndSecond">
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
    StartHour: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_start_hour
      },
      set(value) {
        this.$store.commit(MutationNames.setCollectionEventTimeStartHour, value)
      }
    },
    StartMinute: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_start_minute
      },
      set(value) {
        this.$store.commit(MutationNames.setCollectionEventTimeStartMinute, value)
      }
    },
    StartSecond: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_start_second
      },
      set(value) {
        this.$store.commit(MutationNames.setCollectionEventTimeStartSecond, value)
      },
    },
    EndHour: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_end_hour
      },
      set(value) {
        this.$store.commit(MutationNames.setCollectionEventTimeEndHour, value)
      }
    },
    EndMinute: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_end_minute
      },
      set(value) {
        this.$store.commit(MutationNames.setCollectionEventTimeEndMinute, value)
      }
    },
    EndSecond: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_end_second
      },
      set(value) {
        this.$store.commit(MutationNames.setCollectionEventTimeEndSecond, value)
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
