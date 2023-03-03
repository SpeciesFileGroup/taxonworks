<template>
  <FacetGeographicArea
    v-model="params"
    input-id="area_picker_autocomplete"
  />
  <FacetWKT v-model="params" />
  <FacetCollectingEvent v-model="params" />
  <FacetParamExact
    title="OTU"
    v-model="params"
    param="name"
  />
  <FacetTaxonName
    v-model="params"
    coverage
  />
  <FacetHistorialDeterminations v-model="params" />
  <FacetBiologicalRelationship v-model="params" />
  <FacetDescriptor v-model="params" />
  <FacetDataAttribute v-model="params" />
  <FacetUsers v-model="params" />
  <FacetTags
    v-model="params"
    target="Otu"
  />
  <FacetIdentifiers v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
  <FacetCoordinatify v-model="params" />
</template>

<script setup>
import { computed } from 'vue'
import FacetBiologicalRelationship from 'components/Filter/Facets/BiologicalAssociation/FacetBiologicalRelationship.vue'
import FacetCollectingEvent from 'tasks/biological_associations/filter/components/Facet/FacetCollectingEvent.vue'
import FacetDataAttribute from 'components/Filter/Facets/shared/FacetDataAttribute.vue'
import FacetDescriptor from 'components/Filter/Facets/shared/FacetDescriptor.vue'
import FacetGeographicArea from 'components/Filter/Facets/shared/FacetGeographic.vue'
import FacetHistorialDeterminations from './Facet/FacetHistorialDeterminations.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetWKT from 'components/Filter/Facets/Otu/FacetWKT.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetIdentifiers from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetParamExact from 'components/Filter/Facets/shared/FacetParamExact.vue'
import FacetCoordinatify from 'components/Filter/Facets/Otu/FacetCoordinatify.vue'

const WITH_PARAMS = [
  'asserted_distributions',
  'biological_associations',
  'citations',
  'collection_objects',
  'contents,',
  'depictions',
  'determinations',
  'observations',
  'origin_citation',
  'taxon_name'
]

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
