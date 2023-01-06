<template>
  <FacetTaxonName
    coverage
    relation
    v-model="params"
  />
  <FacetGeographic v-model="params" />
  <FacetWKT v-model="params" />
  <FacetBiologicalRelationship v-model="params" />
  <FacetBiologicalProperty v-model="params" />
  <FacetOtu
    v-model="params"
    target="BiologicalAssociation"
  />
  <FacetCollectionObject v-model="params" />
  <FacetCollectingEvent v-model="params" />
  <FacetNotes v-model="params" />
  <FacetIdentifier v-model="params" />
  <FacetTags
    v-model="params"
    target="CollectionObject"
  />
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
import FacetGeographic from 'components/Filter/Facets/shared/FacetGeographic.vue'
import FacetWKT from 'components/Filter/Facets/Otu/FacetWKT.vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetIdentifier from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetBiologicalRelationship from 'components/Filter/Facets/BiologicalAssociation/FacetBiologicalRelationship.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetNotes from 'components/Filter/Facets/shared/FacetNotes.vue'
import FacetCollectionObject from 'components/Filter/Facets/CollectionObject/FacetCollectionObject.vue'
import FacetCollectingEvent from './Facet/FacetCollectingEvent.vue'
import FacetBiologicalProperty from 'components/Filter/Facets/BiologicalAssociation/FacetBiologicalProperty.vue'
import FacetOtu from 'components/Filter/Facets/Otu/FacetOtu.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import { computed } from 'vue'

const WITH_PARAMS = [
  'citations',
  'origin_citation'
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
