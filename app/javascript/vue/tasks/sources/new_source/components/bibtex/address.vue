<template>
  <div class="label-above">
    <label>Address</label>
    <textarea
      v-model="source.address"
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
