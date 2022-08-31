<template>
  <div class="field">
    <h3>Times repeated</h3>
    <input
      v-model="params.repeated_total"
      type="number"
      class="input-xsmall-width"
    >
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const props = defineProps({
  modelValue: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const params = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

params.value.repeated_total = URLParamsToJSON(location.href).repeated_total
</script>
