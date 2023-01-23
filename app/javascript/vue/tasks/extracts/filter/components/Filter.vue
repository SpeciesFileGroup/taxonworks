<template>
  <FacetExtractOrigin v-model="params" />
  <FacetCollectionObject v-model="params" />
  <FacetTaxonName
    v-model="params"
    coverage
  />
  <FacetOtu
    v-model="params"
    target="Extract"
  />
  <FacetVerbatimAnatomical v-model="params" />
  <FacetWith
    title="Sequences"
    param="sequences"
    v-model="params"
  />
  <FacetDateRange v-model="params.date" />
  <FacetRepository v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetTags
    v-model="params.keywords"
    target="CollectionObject"
  />
  <FacetIdentifiers v-model="params" />
  <FacetProtocol v-model="params" />
  <FacetUsers v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
</template>

<script setup>
import { computed } from 'vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetIdentifiers from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetRepository from 'components/Filter/Facets/CollectionObject/FacetRepository.vue'
import FacetProtocol from 'components/Filter/Facets/Extract/FacetProtocol.vue'
import FacetOtu from 'components/Filter/Facets/Otu/FacetOtu.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetDateRange from 'components/Filter/Facets/Extract/FacetDateRange.vue'
import FacetCollectionObject from 'components/Filter/Facets/CollectionObject/FacetCollectionObject.vue'
import FacetExtractOrigin from 'components/Filter/Facets/Extract/FacetExtractOrigin.vue'
import FacetVerbatimAnatomical from 'components/Filter/Facets/Extract/FacetVerbatimAnatomical.vue'
import FacetMatchIdentifiers from 'components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'

const WITH_PARAMS = ['citations', 'origin_citation']

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
