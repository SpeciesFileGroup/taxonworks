<template>
  <FacetByAttributeRow
    v-model="params"
    controller="dwc_occurrences"
  />
</template>

<script setup>
import { computed } from 'vue'
import FacetByAttributeRow from '@/components/Filter/Facets/shared/FacetByAttributeRow/FacetByAttributeRow.vue'

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
