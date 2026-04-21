<template>
  <div
    class="flex flex-row gap-small middle padding-small padding-medium-left padding-medium-right"
  >
    <div
      v-for="type in uniqueTypes"
      :key="type"
      class="flex flex-row middle gap-xsmall"
    >
      <div :class="['legend-square', TYPES[type]?.background]" />
      <span>{{ TYPES[type]?.label }}</span>
    </div>
    <div
      v-if="preview"
      class="flex flex-row middle gap-xsmall"
    >
      <div class="legend-square bg-verbatim" />
      <span>Preview from verbatim coordinates</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import {
  GEOGRAPHIC_AREA,
  GEOREFERENCE_LEAFLET,
  GEOREFERENCE_POINT,
  GEOREFERENCE_VERBATIM
} from '@/constants'

const TYPES = {
  [GEOGRAPHIC_AREA]: {
    label: 'Geographic Area',
    background: 'bg-asserted-distribution'
  },
  [GEOREFERENCE_VERBATIM]: {
    label: 'Georeference (verbatim)',
    background: 'bg-verbatim'
  },
  [GEOREFERENCE_POINT]: {
    label: 'Georeference',
    background: 'bg-georeference'
  },
  [GEOREFERENCE_LEAFLET]: {
    label: 'Georeference',
    background: 'bg-georeference'
  }
}

const props = defineProps({
  types: {
    type: Array,
    required: true
  },

  preview: {
    type: [Boolean, String],
    required: true
  }
})

const uniqueTypes = computed(() => {
  const seenLabels = new Set()

  return props.types.filter((type) => {
    const label = TYPES[type]?.label
    if (seenLabels.has(label)) return false
    seenLabels.add(label)
    return true
  })
})
</script>

<style scoped>
.legend-square {
  border-radius: 0.125rem;
  width: 12px;
  height: 12px;
}
</style>
