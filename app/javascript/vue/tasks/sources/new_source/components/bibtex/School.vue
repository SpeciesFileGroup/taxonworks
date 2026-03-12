<template>
  <div class="label-above">
    <label>School</label>
    <input
      type="text"
      v-model="source.school"
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
