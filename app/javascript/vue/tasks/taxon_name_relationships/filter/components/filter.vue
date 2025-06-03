<template>
  <FacetTaxonNameRelationshipType
    v-model="params"
  />

  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
</template>

<script setup>
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetTaxonNameRelationshipType from './filters/FacetTaxonNameRelationshipType.vue'

const WITH_PARAMS = ['citations']

const params = defineModel({
  type: Object,
  default: () => ({})
})

</script>
