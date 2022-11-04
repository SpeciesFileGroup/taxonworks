<template>
  <div>
    <h3>By WKT</h3>
    <input
      type="text"
      v-model="wkt"
    >
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modalValue: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modalValue'])

const wkt = computed({
  get: () => props.modalValue,
  set: value => emit('update:modalValue', value)
})
</script>
