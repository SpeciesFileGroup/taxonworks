<template>
  <div>
    <label><b>Elevation</b></label>
    <div class="horizontal-left-content">
      <div class="separate-right">
        <label>Minimum</label>
        <input
          type="text"
          v-model="collectingEvent.minimum_elevation"
          @change="updateChange"
        />
      </div>
      <div class="separate-right separate-left">
        <label>Maximum</label>
        <input
          type="text"
          v-model="collectingEvent.maximum_elevation"
          @change="updateChange"
        />
      </div>
      <div class="separate-right separate-left">
        <label>Precision</label>
        +/-
        <input
          type="text"
          v-model="collectingEvent.elevation_precision"
          @change="updateChange"
        />
      </div>
      <div>
        Unit
        <label>
          <input
            v-model="collectingEvent.units"
            type="radio"
            :value="undefined"
            name="elevation"
            @change="updateChange"
          />
          Meters
        </label>
        <label>
          <input
            v-model="collectingEvent.units"
            value="ft"
            type="radio"
            name="elevation"
            @change="updateChange"
          />
          Feet
        </label>
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
