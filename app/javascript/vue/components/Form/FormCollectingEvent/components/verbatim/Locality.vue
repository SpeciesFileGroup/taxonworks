<template>
  <div class="field label-above">
    <label>Locality</label>
    <textarea
      class="full_width"
      type="text"
      name="verbatim-locality"
      rows="5"
      v-model="collectingEvent.verbatim_locality"
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
