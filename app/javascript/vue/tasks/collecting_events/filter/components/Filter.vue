<template>
  <FacetGeographic v-model="params" />
  <FaceDeterminations v-model="params" />
  <FacetIdentifiers v-model="params" />
  <FacetPeople
    v-model="params"
    role="Collector"
    title="Collectors"
    klass="CollectingEvent"
    param-people="collector_id"
    param-any="collector_id_or"
    :role-type="COLLECTOR_SELECTOR"
  />
  <FacetMaterial v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetProtocol v-model="params" />
  <FacetKeywords
    target="CollectingEvent"
    v-model="params"
  />
  <FacetTotalUsed v-model="params" />
  <FacetUsers
    v-model="params"
    :type="COLLECTING_EVENT"
  />
  <FacetCollectingEventAttributes v-model="params" />
  <FacetDataAttribute v-model="params" />
  <FacetImportAttribute v-model="params" />
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
import FacetIdentifiers from '@/components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetGeographic from '@/components/Filter/Facets/shared/FacetGeographic.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetTotalUsed from '@/components/Filter/Facets/shared/FacetTotalUsed.vue'
import FacetCollectingEventAttributes from '@/components/Filter/Facets/CollectingEvent/FacetCollectingEvent/FacetCollectingEvent.vue'
import FacetKeywords from '@/components/Filter/Facets/shared/FacetTags.vue'
import FaceDeterminations from '@/components/Filter/Facets/CollectionObject/Determiner/FacetDetermination.vue'
import FacetMaterial from '@/components/Filter/Facets/CollectionObject/FacetTypeMaterial.vue'
import FacetPeople from '@/components/Filter/Facets/shared/FacetPeople.vue'
import FacetDataAttribute from '@/components/Filter/Facets/shared/FacetDataAttribute.vue'
import FacetMatchIdentifiers from '@/components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetProtocol from '@/components/Filter/Facets/Extract/FacetProtocol.vue'
import FacetImportAttribute from '@/components/Filter/Facets/shared/FacetImportAttribute/FacetImportAttribute.vue'
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import { computed } from 'vue'
import { COLLECTOR_SELECTOR, COLLECTING_EVENT } from '@/constants/index.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const WITH_PARAMS = [
  'citations',
  'collection_objects',
  'collectors',
  'data_attributes',
  'data_depictions',
  'depictions',
  'geographic_area',
  'georeferences',
  'global_identifiers',
  'identifiers',
  'local_identifiers',
  'notes',
  'origin_citation',
  'protocols',
  'tags'
]

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
