<template>
  <div class="panel content">
    <h3>Metadata</h3>
    <div class="info-grid">
      <div
        v-for="{ label, value } in items"
        :key="label"
        class="info-item"
      >
        <span class="info-label">{{ label }}</span>
        <span
          class="info-value"
          :class="{ muted: !value }"
          >{{ value || 'Not provided' }}</span
        >
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { secondsToTimeString } from '@/helpers'

const props = defineProps({
  sound: {
    type: Object,
    required: true
  }
})

const items = computed(() => {
  const { id, name, metadata, created_at, updated_at } = props.sound

  return [
    { label: 'ID', value: id },
    { label: 'Name', value: name },
    {
      label: 'Duration',
      value: metadata.duration ? secondsToTimeString(metadata.duration) : null
    },
    {
      label: 'Sample rate',
      value: metadata.sample_rate
        ? `${(metadata.sample_rate / 1000).toFixed(1)} kHz`
        : null
    },
    { label: 'Created', value: formatDay(created_at) },
    { label: 'Updated', value: formatDay(updated_at) }
  ]
})

function formatDay(date) {
  return date ? new Date(date).toLocaleDateString() : null
}
</script>
