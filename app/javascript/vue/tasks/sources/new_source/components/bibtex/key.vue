<template>
  <div class="horizontal-left-content gap-small">
    <div class="label-above">
      <label>Key</label>
      <input
        type="text"
        v-model="source.key"
        @change="() => (source.isUnsaved = true)"
      />
    </div>

    <div class="label-above">
      <label>Crossref</label>
      <input
        type="text"
        v-model="source.crossref"
        @change="() => (source.isUnsaved = true)"
      />
    </div>
  </div>
</template>

<script setup>
const source = defineModel({
  type: Object,
  required: true
})
</script>

<style scoped>
input[type='number'] {
  width: 80px;
}
</style>
