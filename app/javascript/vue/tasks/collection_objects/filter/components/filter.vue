<template>
  <FacetGeographic v-model="params" />
  <FacetDetermination v-model="params" />
  <FacetTaxonName
    v-model="params"
    coverage
    validity
  />
  <FacetCurrentRepository v-model="params" />
  <FacetRepository v-model="params" />
  <FacetIdentifiers v-model="params" />
  <FacetPreparationTypes v-model="params" />
  <FacetBiocurations v-model="params" />
  <FacetCollectingEvent v-model="params" />
  <FacetPeople
    role="Collector"
    title="Collectors"
    klass="CollectingEvent"
    param-people="collector_id"
    param-any="collector_ids_or"
    v-model="params"
  />
  <FacetMatchIdentifiers v-model="params" />
  <FacetTags
    v-model="params"
    target="CollectionObject"
  />
  <FacetTypeMaterial v-model="params" />
  <FacetInRelationship v-model="params" />
  <FacetLoan v-model="params" />
  <FacetUsers v-model="params" />
  <FacetNotes v-model="params" />
  <FacetBuffered v-model="params" />
  <FacetDataAttribute v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param.replace('with_', '')"
    :param="param"
    v-model="params"
  />
</template>

<script setup>
import { computed } from 'vue'
import FacetDetermination from 'components/Filter/Facets/CollectionObject/Determiner/FacetDetermination.vue'
import FacetCollectingEvent from 'components/Filter/Facets/CollectingEvent/FacetCollectingEvent/FacetCollectingEvent.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetGeographic from 'components/Filter/Facets/shared/FacetGeographic.vue'
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetIdentifiers from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetTypeMaterial from 'components/Filter/Facets/CollectionObject/FacetTypeMaterial.vue'
import FacetLoan from './filters/FacetLoan.vue'
import FacetInRelationship from './filters/relationship/FacetInRelationship'
import FacetBiocurations from 'components/Filter/Facets/CollectionObject/FacetBiocurations.vue'
import FacetRepository from 'components/Filter/Facets/CollectionObject/FacetRepository.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetBuffered from './filters/FacetBuffered.vue'
import FacetPreparationTypes from './filters/FacetPreparationTypes'
import FacetPeople from 'components/Filter/Facets/shared/FacetPeople.vue'
import FacetNotes from 'components/Filter/Facets/shared/FacetNotes.vue'
import FacetCurrentRepository from './filters/FacetCurrentRepository.vue'
import FacetDataAttribute from 'components/Filter/Facets/shared/FacetDataAttribute.vue'
import FacetMatchIdentifiers from 'components/Filter/Facets/shared/FacetMatchIdentifiers.vue'

const WITH_PARAMS = [
  'collecting_event',
  'data_attributes',
  'depictions',
  'geographic_area',
  'georeferences',
  'local_identifiers',
  'taxon_determinations',
  'type_material',
  'current_repository',
  'repository',
  'preparation_type',
  'deaccessioned',
  'dwc_indexed',
  'notes',
  'with_buffered_collecting_event',
  'with_buffered_determinations',
  'with_buffered_other_labels'
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
