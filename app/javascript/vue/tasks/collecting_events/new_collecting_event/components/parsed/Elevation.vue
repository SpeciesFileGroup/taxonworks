<template>
  <div>
    <label><b>Elevation</b></label>
    <div class="horizontal-left-content">
      <div class="field label-above separate-right">
        <label>Minimum</label>
        <input
          type="text"
          class="input-xsmall-width"
          v-model="collectingEvent.minimum_elevation">
      </div>
      <div class="field label-above separate-right">
        <label>Maximum</label>
        <input
          type="text"
          class="input-xsmall-width"
          v-model="collectingEvent.maximum_elevation">
      </div>
      <div class="field label-above separate-right">
        <label>Precision</label>
        <div class="horizontal-left-content">
          <span>+/-</span>
          <input
            type="text"
            class="input-xsmall-width"
            v-model="collectingEvent.elevation_precision">
        </div>
      </div>
      <div>
        Unit
        <ul class="no_bullets">
          <li v-for="unit in units">
            <label>
              <input
                v-model="collectingEvent.units"
                type="radio"
                :value="unit.value"
                name="elevation">
              {{ unit.label }}
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
  mixins: [extendCE],
  data() {
    return {
      units: [
        {
          label: 'Meters',
          value: undefined
        },
        {
          label: 'Feet',
          value: 'ft'
        }
      ]
    }
  }
}
</script>