<template>
  <ul class="no_bullets">
    <li>
      <label>
        <input
          :disabled="!observation.id"
          type="radio"
          :value="isPresent"
          :checked="isPresent === undefined"
          @click="emit('destroy')"
        >
        Not specified
      </label>
    </li>
    <li
      v-for="(value, key) in presenceOptions"
      :key="key"
    >
      <label>
        <input
          type="radio"
          v-model="observation.isChecked"
          :value="value"
        >
        {{ key }}
      </label>
    </li>
  </ul>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const presenceOptions = {
  Presence: true,
  Absent: false
}

const emit = defineEmits([
  'update:modelValue',
  'destroy'
])

const observation = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})
</script>
