<template>
  <div class="label-above">
    <label>Copyright</label>
    <input
      type="text"
      v-model="source.copyright"
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
