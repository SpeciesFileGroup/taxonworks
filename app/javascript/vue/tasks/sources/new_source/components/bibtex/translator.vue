<template>
  <div class="field">
    <label>Translator</label><br />
    <input
      type="text"
      v-model="source.translator"
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
