<template>
  <div class="field label-above">
    <label>Geolocation uncertainty in meters</label>
    <input
      class="full_width"
      type="text"
      rows="3"
      v-model="collectingEvent.verbatim_geolocation_uncertainty"
    />
  </div>
</template>

<script setup>
const collectingEvent = defineModel()
</script>
