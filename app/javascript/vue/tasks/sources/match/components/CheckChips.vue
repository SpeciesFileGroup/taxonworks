<template>
  <div class="check-chips">
    <template
      v-for="field in CHIP_FIELDS"
      :key="field.key"
    >
      <VBadge
        v-if="evaluation.checks[field.key] !== CHECK.NONE"
        class="check-chip"
        :color="CHECK_COLORS[evaluation.checks[field.key]]"
        :title="`${field.label}: ${evaluation.details[field.key]}`"
      >
        {{ field.label }}
      </VBadge>
    </template>
  </div>
</template>

<script setup>
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import { CHECK } from '../constants.js'

const CHECK_COLORS = {
  [CHECK.PASS]: 'green',
  [CHECK.DIFFERS]: 'yellow',
  [CHECK.FAIL]: 'red'
}

const CHIP_FIELDS = [
  { key: 'doi', label: 'DOI' },
  { key: 'authors', label: 'Authors' },
  { key: 'year', label: 'Year' },
  { key: 'title', label: 'Title' },
  { key: 'journal', label: 'Journal' },
  { key: 'volume', label: 'Volume' },
  { key: 'page', label: 'Page' }
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
  cursor: help;
}
</style>
