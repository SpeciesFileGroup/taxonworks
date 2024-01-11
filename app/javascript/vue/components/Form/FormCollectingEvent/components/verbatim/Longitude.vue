<template>
  <div class="field label-above">
    <label>Longitude</label>
    <input
      class="full_width"
      type="text"
      v-model="longitude"
    />
  </div>
</template>

<script setup>
import { parseCoordinateCharacters } from '@/helpers/georeferences'
import { computed } from 'vue'

const collectingEvent = defineModel()

const longitude = computed({
  get() {
    return collectingEvent.value.verbatim_longitude
  },
  set(value) {
    collectingEvent.value.verbatim_longitude = parseCoordinateCharacters(value)
  }
})
</script>
