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
  }
})

const emit = defineEmits(['click:cell'])

const tableRef = ref()
const gbifference = ref()

onMounted(() => { initGbifference(props) })

const initGbifference = (opt) => {
  const element = tableRef.value

  gbifference.value = new TableGbifference(element, opt)
  gbifference.value.on('click:cell', (e) => { emit('click:cell', e) })
}

watch(
  () => props,
  newProps => {
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
</style>
