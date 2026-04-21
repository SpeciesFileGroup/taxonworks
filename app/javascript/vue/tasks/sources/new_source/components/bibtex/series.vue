<template>
  <div class="field">
    <label>Series</label><br />
    <input
      type="text"
      v-model="source.series"
      @change="source.isUnsaved = true"
    />
  </div>
</template>

<script setup>
const source = defineModel({
  type: Object,
  required: true
})
</script>
