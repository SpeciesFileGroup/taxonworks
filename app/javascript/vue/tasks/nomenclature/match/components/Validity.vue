<template>
  <ul class="context-menu middle">
    <li
      v-for="(value, label) in OPTIONS"
      :key="label"
    >
      <label class="capitalize">
        <input
          type="radio"
          :value="value"
          v-model="validity"
        />
        {{ label }}
      </label>
    </li>
  </ul>
</template>

<script setup>
import { computed } from 'vue'

const OPTIONS = {
  valid: true,
  invalid: false,
  both: undefined
}

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const validity = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
