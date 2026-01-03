<template>
  <div class="label-above">
    <label>Booktitle</label>
    <textarea
      v-model="source.booktitle"
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
