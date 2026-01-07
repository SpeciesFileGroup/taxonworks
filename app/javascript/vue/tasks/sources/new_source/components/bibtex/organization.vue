<template>
  <div class="label-above">
    <label>Organization</label>
    <input
      type="text"
      v-model="source.organization"
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
