<template>
  <div class="field">
    <ul class="no_bullets">
      <li
        v-for="({ label, value }) in VALIDITY_OPTIONS"
        :key="label"
      >
        <label>
          <input
            type="radio"
            :value="value"
            v-model="params.validity"
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </div>
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
  set: value => emit('update:modelValue', value)
})

const VALIDITY_OPTIONS = [
  {
    label: 'Both valid/invalid',
    value: true
  },
  {
    label: 'Valid only',
    value: undefined
  },
  {
    label: 'Invalid only',
    value: false
  }
]
</script>
