<template>
  <div class="middle">
    <label>
      <input
        type="checkbox"
        :disabled="disabled"
        v-model="prioritize"
      >
      Prioritize Geographic area when indexing
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
