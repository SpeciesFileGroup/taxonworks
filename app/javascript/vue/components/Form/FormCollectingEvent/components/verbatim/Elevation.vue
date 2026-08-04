<template>
  <div class="label-above">
    <label>Elevation</label>
    <input
      class="full_width"
      type="text"
      rows="3"
      v-model="collectingEvent.verbatim_elevation"
      @change="
        () => {
          collectingEvent.isUnsaved = true
        }
      "
    />
  </div>
</template>

<script setup>
const collectingEvent = defineModel()
</script>
