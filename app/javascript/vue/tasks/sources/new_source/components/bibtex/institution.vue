<template>
  <div class="label-above">
    <label>Institution</label>
    <input
      type="text"
      v-model="source.institution"
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
