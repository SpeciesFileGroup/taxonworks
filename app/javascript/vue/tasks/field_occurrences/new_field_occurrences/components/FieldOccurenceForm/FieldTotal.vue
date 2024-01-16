<template>
  <div class="label-above">
    <label>Total</label>
    <input
      type="number"
      v-model="fieldOccurence.total"
    />
  </div>
</template>

<script setup>
const fieldOccurence = defineModel()
</script>
