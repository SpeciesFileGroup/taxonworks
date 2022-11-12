<template>
  <div>
    <h3>By WKT</h3>
    <input
      class="full_width"
      type="text"
      v-model="wkt"
    >
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const wkt = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})
</script>
