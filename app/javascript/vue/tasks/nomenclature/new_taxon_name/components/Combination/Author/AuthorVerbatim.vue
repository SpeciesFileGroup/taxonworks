<template>
  <div>
    <div class="field label-above">
      <label>Verbatim author</label>
      <input
        type="text"
        v-model="combination.verbatim_author">
    </div>
    <div class="fields label-above">
      <label>Verbatim year</label>
      <input
        type="number"
        v-model="combination.year_of_publication">
    </div>
  </div>
</template>

<script setup>

import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const combination = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

</script>
