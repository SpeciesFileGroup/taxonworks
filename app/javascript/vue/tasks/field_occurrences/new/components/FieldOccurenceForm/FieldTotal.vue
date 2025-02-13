<template>
  <div class="label-above">
    <label>Total</label>
    <input
      type="number"
      min="0"
      v-model="fieldOccurence.total"
      @change="() => { fieldOccurence.isUnsaved = true }"
    />
  </div>
</template>

<script setup>
const fieldOccurence = defineModel()
</script>
