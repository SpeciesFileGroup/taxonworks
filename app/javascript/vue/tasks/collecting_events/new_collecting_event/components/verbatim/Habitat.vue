<template>
  <div class="field label-above">
    <label>Habitat</label>
    <input
      class="full_width"
      type="text"
      v-model="collectingEvent.verbatim_habitat"
    />
  </div>
</template>

<script setup>
const collectingEvent = defineModel()
</script>
