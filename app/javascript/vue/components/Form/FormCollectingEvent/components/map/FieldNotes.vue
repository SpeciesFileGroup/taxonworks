<template>
  <div class="field label-above">
    <label>Field notes</label>
    <textarea
      class="full_width"
      rows="5"
      v-model="collectingEvent.field_notes"
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
