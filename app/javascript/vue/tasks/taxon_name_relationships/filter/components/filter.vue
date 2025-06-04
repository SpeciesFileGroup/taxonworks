<template>
  <FacetTaxonNameRelationshipType
    v-model="params"
  />

  <FacetUsers v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
  <FacetDiffModel v-model="params" />
</template>

<script setup>
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetTaxonNameRelationshipType from './filters/FacetTaxonNameRelationshipType.vue'

const WITH_PARAMS = ['citations', 'notes', 'verifiers']

const params = defineModel({
  type: Object,
  default: () => ({})
})

</script>
