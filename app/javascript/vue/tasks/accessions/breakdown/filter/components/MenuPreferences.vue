<template>
  <ul class="context-menu">
    <li>
      <label>
        <input
          type="checkbox"
          v-model="preferences.activeFilter">
        Show filter
      </label>
    </li>
    <li>
      <label>
        <input
          type="checkbox"
          v-model="preferences.activeJSONRequest">
        Show JSON Request
      </label>
    </li>
  </ul>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits([
  'update:modelValue'
])

const preferences = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

</script>
