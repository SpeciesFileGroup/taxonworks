<template>
  <div class="check-chips">
    <template
      v-for="field in CHIP_FIELDS"
      :key="field.key"
    >
      <span
        v-if="evaluation.checks[field.key] !== CHECK.NONE"
        :class="['check-chip', `check-chip--${evaluation.checks[field.key]}`]"
        :title="`${field.label}: ${evaluation.details[field.key]}`"
      >
        {{ field.label }}
      </span>
    </template>
  </div>
</template>

<script setup>
import { CHECK } from '../constants.js'

const CHIP_FIELDS = [
  { key: 'doi', label: 'DOI' },
  { key: 'authors', label: 'Authors' },
  { key: 'year', label: 'Year' },
  { key: 'title', label: 'Title' },
  { key: 'journal', label: 'Journal' },
  { key: 'volume', label: 'Volume' },
  { key: 'firstPage', label: 'Page' }
]

defineProps({
  evaluation: {
    type: Object,
    required: true
  }
})
</script>

<style scoped>
.check-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 2px;
}

.check-chip {
  padding: 0 0.35rem;
  border-radius: 4px;
  font-size: 0.75rem;
  cursor: help;
}

.check-chip--pass {
  background-color: var(--badge-green-bg);
  color: var(--badge-green-color);
}

.check-chip--differs {
  background-color: var(--badge-yellow-bg);
  color: var(--badge-yellow-color);
}

.check-chip--fail {
  background-color: var(--badge-red-bg);
  color: var(--badge-red-color);
}
</style>
