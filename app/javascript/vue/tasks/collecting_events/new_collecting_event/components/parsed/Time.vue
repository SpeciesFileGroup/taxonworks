<template>
  <div>
    <div>
      <label class="separate-bottom"><b>Start time</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="margin-small-right label-above">
          <label>Hour</label>
          <input
            type="number"
            class="input-xsmall-width"
            min="0"
            max="23"
            v-model="collectingEvent.time_start_hour">
        </div>
        <div class="margin-small-right label-above">
          <label>Minute</label>
          <input
            type="number"
            class="input-xsmall-width"
            min="0"
            max="60"
            v-model="collectingEvent.time_start_minute">
        </div>
        <div class="label-above">
          <label>Seconds</label>
          <input
            type="number"
            class="input-xsmall-width"
            min="0"
            max="60"
            v-model="collectingEvent.time_start_second">
        </div>
      </div>
    </div>
    <div>
      <label class="separate-bottom"><b>End time</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="margin-small-right label-above">
          <label>Hour</label>
          <input
            type="number"
            class="input-xsmall-width"
            min="0"
            max="23"
            v-model="collectingEvent.time_end_hour">
        </div>
        <div class="margin-small-right label-above">
          <label>Minute</label>
          <input
            type="number"
            class="input-xsmall-width"
            min="0"
            max="60"
            v-model="collectingEvent.time_end_minute">
        </div>
        <div class="label-above">
          <label>Seconds</label>
          <input
            type="number"
            class="input-xsmall-width"
            min="0"
            max="60"
            v-model="collectingEvent.time_end_second">
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
