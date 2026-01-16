<template>
  <AttributionForm
    :klass="klass"
    button-label="Remove"
    button-color="destroy"
    @attribution="(attribution) => emit('select', attribution)"
  />
</template>

<script setup>
import AttributionForm from './attributions.vue'

defineProps({
  klass: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['select'])
</script>
