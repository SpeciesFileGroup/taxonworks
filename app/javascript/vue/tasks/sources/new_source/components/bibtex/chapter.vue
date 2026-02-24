<template>
  <div class="label-above">
    <label>Chapter</label>
    <input
      type="text"
      v-model="source.chapter"
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
