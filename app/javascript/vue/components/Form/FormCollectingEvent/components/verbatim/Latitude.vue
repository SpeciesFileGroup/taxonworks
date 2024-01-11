<template>
  <div class="field label-above">
    <label>Latitude</label>
    <input
      class="full_width"
      type="text"
      v-model="latitude"
    />
  </div>
</template>

<script setup>
import { parseCoordinateCharacters } from '@/helpers/georeferences'
import { computed } from 'vue'

const collectingEvent = defineModel()

const latitude = computed({
  get() {
    return collectingEvent.value.verbatim_latitude
  },
  set(value) {
    collectingEvent.value.verbatim_latitude = parseCoordinateCharacters(value)
  }
})
</script>
