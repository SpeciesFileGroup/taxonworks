<template>
  <AttributionForm
    :klass="klass"
    :licenses="licenses"
    :role-types="roleTypes"
    @attribution="(attribution) => emit('select', attribution)"
  />
</template>

<script setup>
import AttributionForm from './attributions.vue'

defineProps({
  klass: {
    type: String,
    required: true
  },

  licenses: {
    type: Array,
    default: () => []
  },

  roleTypes: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select'])
</script>
