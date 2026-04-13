<template>
  <div class="middle">
    <label>
      <input
        type="checkbox"
        :disabled="disabled"
        v-model="prioritize"
      >
      Use GeographicArea, not Georeference, to assign geography fields in Darwin Core
    </label>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: undefined
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits('update:modelValue')

const prioritize = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value || null)
})
</script>
