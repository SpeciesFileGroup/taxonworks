<template>
  <div class="label-above">
    <label>Publisher</label>
    <input
      type="text"
      v-model="source.publisher"
      @change="() => (source.isUnsaved = true)"
    />
  </div>
</template>

<script setup>
const source = defineModel({
  type: Object,
  required: true
})
</script>
