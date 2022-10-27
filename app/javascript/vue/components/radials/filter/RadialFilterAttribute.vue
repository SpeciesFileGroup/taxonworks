<template>
  <span
    v-for="(value, key) in parameters"
    :key="key"
    :[getFilterAttribute(key)]="parseValue(value)"
    hidden
  />
</template>

<script setup>
import { DATA_ATTRIBUTE_FILTER_PROPERTY } from 'constants/index.js'
defineProps({
  parameters: {
    type: Object,
    default: () => {}
  }
})

function getFilterAttribute (attr) {
  return `${DATA_ATTRIBUTE_FILTER_PROPERTY}-${attr}`
}

function parseValue (value) {
  return Array.isArray(value)
    ? `[${value}]`
    : value
}
</script>
