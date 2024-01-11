<template>
  <div>
    <label>
      <input
        type="checkbox"
        v-model="fieldOccurence.is_absent"
      />
      Is absent</label
    >
  </div>
</template>

<script setup>
const fieldOccurence = defineModel()
</script>
