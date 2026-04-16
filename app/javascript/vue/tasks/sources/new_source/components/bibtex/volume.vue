<template>
  <div class="horizontal-left-content gap-small">
    <div
      v-for="field in VOLUME_FIELDS"
      :key="field"
      class="label-above"
    >
      <label class="capitalize">{{ field }}</label>
      <input
        type="text"
        v-model="source[field]"
        @change="() => (source.isUnsaved = true)"
      />
    </div>
  </div>
</template>

<script setup>
const VOLUME_FIELDS = ['volume', 'number', 'pages']

const source = defineModel({
  type: Object,
  required: true
})
</script>
