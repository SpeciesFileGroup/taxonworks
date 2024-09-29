<template>
  <div class="field label-above">
    <label>Field number</label>
    <textarea
      class="full_width"
      type="text"
      rows="3"
      v-model="collectingEvent.verbatim_field_number"
    />
  </div>
</template>

<script setup>
const collectingEvent = defineModel()
</script>
