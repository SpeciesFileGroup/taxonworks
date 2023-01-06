<template>
  <span
    v-bind="attributes"
    hidden
  />
</template>

<script setup>
import { DATA_ATTRIBUTE_FILTER_PROPERTY } from 'constants/index.js'
import { computed } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    default: () => {}
  }
})

const attributes = computed(() => {
  const obj = {}

  for (const key in props.parameters) {
    obj[getFilterAttribute(key)] = parseValue(props.parameters[key])
  }

  return obj
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
