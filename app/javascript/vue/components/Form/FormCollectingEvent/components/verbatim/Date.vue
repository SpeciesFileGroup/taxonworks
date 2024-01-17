<template>
  <div class="field label-above">
    <label>Date</label>
    <input
      class="full_width"
      type="text"
      rows="3"
      v-model="collectingEvent.verbatim_date"
      @change="() => { collectingEvent.isUnsaved = true }"
    />
  </div>
</template>

<script setup>
const collectingEvent = defineModel()
</script>
