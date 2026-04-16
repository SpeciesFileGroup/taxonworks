<template>
  <div>
    <label><b>Elevation</b></label>
    <div class="horizontal-left-content">
      <div class="field label-above separate-right">
        <label>Minimum</label>
        <input
          type="text"
          class="input-xsmall-width"
          v-model="collectingEvent.minimum_elevation"
          @change="() => { collectingEvent.isUnsaved = true }"
        />
      </div>
      <div class="field label-above separate-right">
        <label>Maximum</label>
        <input
          type="text"
          class="input-xsmall-width"
          v-model="collectingEvent.maximum_elevation"
          @change="() => { collectingEvent.isUnsaved = true }"
        />
      </div>
      <div class="field label-above separate-right">
        <label>Precision</label>
        <div class="horizontal-left-content">
          <span>+/-</span>
          <input
            type="text"
            class="input-xsmall-width"
            v-model="collectingEvent.elevation_precision"
            @change="() => { collectingEvent.isUnsaved = true }"
          />
        </div>
      </div>
      <div>
        Unit
        <ul class="no_bullets">
          <li
            v-for="unit in units"
            :key="unit.value"
          >
            <label>
              <input
                v-model="collectingEvent.unit"
                type="radio"
                :value="unit.value"
                name="elevation"
                @change="() => { collectingEvent.isUnsaved = true }"
              />
              {{ unit.label }}
            </label>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup>
const collectingEvent = defineModel()

const units = [
  {
    label: 'Meters',
    value: undefined
  },
  {
    label: 'Feet',
    value: 'ft'
  }
]
</script>
