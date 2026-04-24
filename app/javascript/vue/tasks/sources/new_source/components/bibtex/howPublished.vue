<template>
  <div class="label-above">
    <label>How published</label>
    <input
      type="text"
      v-model="source.howpublished"
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
