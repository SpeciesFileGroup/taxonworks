<template>
  <div class="label-above">
    <label>Free text</label>
    <textarea
      class="full_width"
      rows="5"
      v-model="observation.description"
    >
    </textarea>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const observation = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})
</script>
