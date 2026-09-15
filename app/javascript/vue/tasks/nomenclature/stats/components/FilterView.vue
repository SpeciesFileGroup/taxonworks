<template>
  <FacetScopeTaxonName
    :taxon-name="taxonName"
    :supported-ranks="supportedRanks"
    @select="emit('select-taxon-name', $event)"
  />
  <FacetRanks
    title="Display rows"
    param="ranks"
    :taxon-name="taxonName"
    :rank-list="rankList"
    v-model="params"
  />
  <FacetRanks
    title="Count columns"
    param="rank_data"
    :taxon-name="taxonName"
    :rank-list="rankList"
    v-model="params"
  />
  <FacetOptions v-model="params" />
</template>

<script setup>
import { computed } from 'vue'
import FacetScopeTaxonName from './facets/FacetScopeTaxonName.vue'
import FacetRanks from './facets/FacetRanks.vue'
import FacetOptions from './facets/FacetOptions.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  taxonName: {
    type: Object,
    default: undefined
  },

  rankList: {
    type: Object,
    default: () => ({})
  },

  supportedRanks: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue', 'select-taxon-name'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
