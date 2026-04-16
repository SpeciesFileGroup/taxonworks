<template>
  <div>
    <label>
      <input
        type="checkbox"
        v-model="fieldOccurence.is_absent"
        @change="() => { fieldOccurence.isUnsaved = true }"
      />
      Is absent</label
    >
  </div>
</template>

<script setup>
const fieldOccurence = defineModel()
</script>
