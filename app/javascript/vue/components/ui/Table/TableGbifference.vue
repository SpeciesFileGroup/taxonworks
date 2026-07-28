<template>
  <div ref="tableRef" />
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { TableGbifference } from '@sfgrp/gbifference'

const props = defineProps({
  occurrenceId: {
    type: String,
    default: undefined
  },

  datasetKey: {
    type: String,
    default: undefined
  },

  source: {
    type: Object,
    required: true
  },

  headers: {
    type: Object,
    default: () => ({
      source: 'Source (TaxonWorks)'
    })
  }
})

const emit = defineEmits(['click:cell'])

const tableRef = ref()
const gbifference = ref()

onMounted(() => {
  initGbifference(props)
})

const initGbifference = (opt) => {
  const element = tableRef.value

  gbifference.value = new TableGbifference(element, opt)
  gbifference.value.on('click:cell', (e) => {
    emit('click:cell', e)
  })
}

watch(
  () => props,
  (newProps) => {
    console.log(newProps)
    initGbifference(newProps)
  },
  { deep: true }
)
</script>

<style>
.table-gbifference {
  width: 100%;
}

.table-gbifference__remark {
  padding: var(--spacing-xxs) var(--spacing-xs);
  border-radius: var(--border-radius-xsmall);
  font-size: var(--font-size-xs);
  width: min-content;
}

.v-badge--default {
  background-color: var(--badge-default-bg);
  color: var(--badge-default-color);
}

.table-gbifference__remark--altered {
  background-color: var(--badge-yellow-bg);
  color: var(--badge-yellow-color);
}

.table-gbifference__remark--inferred {
  background-color: var(--badge-blue-bg);
  color: var(--badge-blue-color);
}

.table-gbifference__remark--excluded {
  background-color: var(--badge-red-bg);
  color: var(--badge-red-color);
}
</style>
