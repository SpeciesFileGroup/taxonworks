<template>
  <div class="label-above">
    <label>Edition</label>
    <input
      type="text"
      v-model="source.edition"
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
