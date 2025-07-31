<template>
  <div class="field label-above">
    <label>Collectors</label>
    <textarea
      class="full_width"
      rows="5"
      v-model="collectingEvent.verbatim_collectors"
      @change="() => { collectingEvent.isUnsaved = true }"
    />
  </div>
</template>

<script setup>
const collectingEvent = defineModel()
</script>
