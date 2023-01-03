<template>
  <FacetUsers v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="WITH_TITLE[param] || param"
    :param="param"
    v-model="params"
  />
</template>

<script setup>

import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import { computed } from 'vue'

const WITH_TITLE = {
  with_buffered_determinations: 'Buffered determinations',
  with_buffered_collecting_event: 'Buffered collecting event',
  with_buffered_other_labels: 'Buffered other labels'
}

const WITH_PARAMS = [
  'local_identifiers',
  'collecting_event',
  'taxon_determinations',
  'with_buffered_determinations',
  'with_buffered_collecting_event',
  'with_buffered_other_labels'
]

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
