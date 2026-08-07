<template>
  <label>
    <input
      type="checkbox"
      v-model="value"
    />
    Coordinate OTUs
  </label>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const value = computed({
  get: () => params.value.coordinate_otus,
  set: (value) => {
    if (value === false) {
      params.value.coordinate_otus = undefined
    }
  }
})
</script>
