<template>
  <div class="label-above">
    <label>Url</label>
    <input
      type="text"
      v-model="source.url"
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
