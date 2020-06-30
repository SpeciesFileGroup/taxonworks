<template>
  <div>
    <label><b>Elevation</b></label>
    <div class="horizontal-left-content">
      <div class="field label-above separate-right">
        <label>Minimum</label>
        <input
          type="text"
          v-model="collectingEvent.minimum_elevation">
      </div>
      <div class="field label-above separate-right separate-left">
        <label>Maximum</label>
        <input
          type="text"
          v-model="collectingEvent.maximum_elevation">
      </div>
      <div class="field label-above separate-right separate-left">
        <label>Precision</label>
        +/-
        <input
          type="text"
          v-model="collectingEvent.elevation_precision">
      </div>
      <div>
        Unit
        <ul class="no_bullets">
          <li>
            <label>
              <input
                type="radio"
                name="elevation">
              Meters
            </label>
          </li>
          <li>
            <label>
              <input
                type="radio"
                name="elevation">
              Feet
            </label>
          </li>
        </ul>
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