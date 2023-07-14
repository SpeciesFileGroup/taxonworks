<template>
  <div class="field">
    <h3>Referenced in project</h3>
    <ul class="no_bullets">
      <li
        v-for="(option, index) in options"
        :key="index"
      >
        <label>
          <input
            type="radio"
            v-model="inputValue"
            :value="option.value"
          />
          {{ option.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { getCurrentProjectId } from '@/helpers/project.js'
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const inputValue = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

const options = [
  {
    label: 'Any',
    value: []
  },
  {
    label: 'Current',
    value: [getCurrentProjectId()]
  }
]
</script>
