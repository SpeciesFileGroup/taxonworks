<template>
  <div>
    <h3>Verbatim anatomical origin</h3>
    <div class="field label-above">
      <label>Verbatim anatomical origin</label>
      <input
        type="text"
        class="full_width"
        v-model="verbatimAnatomical.verbatim_anatomical_origin"
      >
      <label>
        <input
          type="checkbox"
          v-model="verbatimAnatomical.exact_verbatim_anatomical_origin"
        >
        Exact
      </label>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({
      verbatim_anatomical_origin: undefined,
      exact_verbatim_anatomical_origin: undefined
    })
  }
})

const emit = defineEmits(['update:modelValue'])

const verbatimAnatomical = computed({
  get: () => props.modelValue,
  set: value => { emit('update:modelValue', value)}
})
</script>
