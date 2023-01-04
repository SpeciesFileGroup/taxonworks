<template>
  <div class="field">
    <label>Coverage</label>
    <ul class="no_bullets">
      <li
        v-for="(value, key) in COVERAGE_OPTIONS"
        :key="key"
      >
        <label>
          <input
            type="radio"
            :value="value"
            v-model="params.descendants"
          >
          {{ key }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const COVERAGE_OPTIONS = {
  Descendants: true,
  Exact: undefined
}

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
</script>
