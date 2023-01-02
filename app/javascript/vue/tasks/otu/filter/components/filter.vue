<template>
  <FacetGeographicArea
    v-model="params"
    input-id="area_picker_autocomplete"
  />
  <FacetWKT v-model="params" />
  <FacetCollectingEvent
    v-model="params"
  />
  <FacetTaxonName v-model="params" />
  <FacetHistorialDeterminations v-model="params" />
  <FacetBiologicalRelationship v-model="params" />
  <FacetDescriptor v-model="params" />
  <FacetDataAttribute v-model="params" />
  <FacetCitations
    title="Citations"
    v-model="params"
  />
  <FacetWith
    v-for="param in WITH_PARAM"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
</template>

<script setup>
import { computed } from 'vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetGeographicArea from 'components/Filter/Facets/shared/FacetGeographic.vue'
import FacetCitations from 'components/Filter/Facets/Citations/FacetCitations.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetWKT from 'components/Filter/Facets/Otu/FacetWKT.vue'
import FacetBiologicalRelationship from 'components/Filter/Facets/BiologicalAssociation/FacetBiologicalRelationship.vue'
import FacetCollectingEvent from 'tasks/biological_associations/filter/components/Facet/FacetCollectingEvent.vue'
import FacetDataAttribute from 'components/Filter/Facets/shared/FacetDataAttribute.vue'
import FacetDescriptor from './Facet/FacetDescriptor.vue'
import FacetHistorialDeterminations from './Facet/FacetHistorialDeterminations.vue'

const WITH_PARAM = [
  'biological_associations',
  'asserted_distributions',
  'daterminations',
  'depictions',
  'observations'
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
  set: value => emit('update:modelValue', value)
})

</script>
