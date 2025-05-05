<template>
  <FacetByAttribute
    v-model="params"
    controller="dwc_occurrences"
  />
</template>

<script setup>
import { computed } from 'vue'
import FacetByAttribute from '@/components/Filter/Facets/shared/FacetByAttribute.vue'

const emit = defineEmits(['update:modelValue'])

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
