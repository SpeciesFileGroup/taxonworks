<template>
  <div class="field label-above">
    <label>Trip identifier</label>
    <textarea
      class="full_width"
      type="text"
      rows="3"
      v-model="collectingEvent.verbatim_field_number"
      @change="() => { collectingEvent.isUnsaved = true }"
    />
  </div>
</template>

<script setup>
const collectingEvent = defineModel()
</script>
