<template>
  <div>
    <div>
      <label class="separate-bottom"><b>Start time</b></label>
      <div class="horizontal-left-content separate-bottom">
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
      <label class="separate-bottom"><b>End time</b></label>
      <div class="horizontal-left-content separate-bottom">
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
        this.$store.commit(MutationNames.SetCollectionEventTimeStartHour, value)
      }
    },
    StartMinute: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_start_minute
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventTimeStartMinute, value)
      }
    },
    StartSecond: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_start_second
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventTimeStartSecond, value)
      },
    },
    EndHour: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_end_hour
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventTimeEndHour, value)
      }
    },
    EndMinute: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_end_minute
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventTimeEndMinute, value)
      }
    },
    EndSecond: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].time_end_second
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventTimeEndSecond, value)
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
