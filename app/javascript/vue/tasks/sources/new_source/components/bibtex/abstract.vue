<template>
  <div class="label-above">
    <label>Abstract</label>
    <textarea
      v-model="source.abstract"
      @change="() => (source.isUnsaved = true)"
    ></textarea>
  </div>
</template>

<script setup>
const source = defineModel({
  type: Object,
  required: true
})
</script>
