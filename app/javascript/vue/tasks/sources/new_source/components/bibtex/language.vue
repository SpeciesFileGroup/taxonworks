<template>
  <div class="field label-above">
    <label>Language</label>
    <input
      type="text"
      v-model="source.language"
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
