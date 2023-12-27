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
            v-model="collectingEvent.time_start_hour"
            @change="updateChange"
          />
        </div>
        <div class="separate-left separate-right">
          <label>Minute</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="collectingEvent.time_start_minute"
            @change="updateChange"
          />
        </div>
        <div class="separate-left">
          <label>Seconds</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="collectingEvent.time_start_second"
            @change="updateChange"
          />
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
            v-model="collectingEvent.time_end_hour"
            @change="updateChange"
          />
        </div>
        <div class="separate-left separate-right">
          <label>Minute</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="collectingEvent.time_end_minute"
            @change="updateChange"
          />
        </div>
        <div class="separate-left">
          <label>Seconds</label>
          <input
            type="number"
            min="0"
            max="60"
            v-model="collectingEvent.time_end_second"
            @change="updateChange"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE]
}
</script>

<style scoped>
input {
  max-width: 60px;
}
</style>
