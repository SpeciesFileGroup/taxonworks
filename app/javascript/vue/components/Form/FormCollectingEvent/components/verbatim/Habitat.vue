<template>
  <div class="field label-above">
    <label>Habitat</label>
    <input
      class="full_width"
      type="text"
      v-model="collectingEvent.verbatim_habitat"
      @change="() => { collectingEvent.isUnsaved = true }"
    />
  </div>
</template>

<script setup>
const collectingEvent = defineModel()
</script>
