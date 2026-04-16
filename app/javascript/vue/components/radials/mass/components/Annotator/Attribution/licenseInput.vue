<template>
  <div>
    <select v-model="selectedLicense">
      <option
        v-for="license in licenses"
        :key="license.key"
        :value="license.key"
      >
        {{ license.label }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  },

  licenses: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const selectedLicense = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
