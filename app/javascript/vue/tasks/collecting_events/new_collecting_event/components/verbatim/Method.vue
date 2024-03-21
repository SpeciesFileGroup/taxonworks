<template>
  <div class="field label-above">
    <label>Method</label>
    <input
      class="full_width"
      type="text"
      v-model="collectingEvent.verbatim_method"
    />
  </div>
</template>

<script setup>
const collectingEvent = defineModel()
</script>
