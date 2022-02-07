<template>
  <div>
    <h3>Sequences</h3>
    <label>
      <input
        type="checkbox"
        v-model="hasSequence">
      Has sequence
    </label>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const hasSequence = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value || undefined)
})

hasSequence.value = URLParamsToJSON(location.href).sequences

</script>
