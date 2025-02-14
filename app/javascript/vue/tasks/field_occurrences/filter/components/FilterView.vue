<template>
  <FacetGeographic v-model="params" />
  <FacetDetermination v-model="params" />
  <FacetBiocurations v-model="params" />
  <FacetCollectingEvent v-model="params" />
  <FacetDataAttribute v-model="params" />
  <FacetUsers
    v-model="params"
    :type="COLLECTION_OBJECT"
  />
  <FacetTags
    v-model="params"
    :target="COLLECTION_OBJECT"
  />
  <FacetConfidence
    v-model="params"
    :target="COLLECTION_OBJECT"
  />
  <FacetNotes v-model="params" />
  <FacetProtocol v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param.replace('with_', '')"
    :param="param"
    v-model="params"
  />
  <FacetDiffModel v-model="params" />
</template>

<script setup>
import { COLLECTION_OBJECT } from '@/constants/index.js'
import FacetDetermination from '@/components/Filter/Facets/CollectionObject/Determiner/FacetDetermination.vue'
import FacetCollectingEvent from '@/components/Filter/Facets/CollectingEvent/FacetCollectingEvent/FacetCollectingEvent.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetGeographic from '@/components/Filter/Facets/shared/FacetGeographic.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetBiocurations from '@/components/Filter/Facets/CollectionObject/FacetBiocurations.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetNotes from '@/components/Filter/Facets/shared/FacetNotes.vue'
import FacetDataAttribute from '@/components/Filter/Facets/shared/FacetDataAttribute.vue'
import FacetProtocol from '@/components/Filter/Facets/Extract/FacetProtocol.vue'
import FacetConfidence from '@/components/Filter/Facets/shared/FacetConfidence.vue'

const WITH_PARAMS = [
  'biological_associations',
  'citations',
  'collecting_event',
  'confidences',
  'data_attributes',
  'data_depictions',
  'dates',
  'depictions',
  'determiners',
  'geographic_area',
  'georeferences',
  'notes',
  'origin_citation',
  'protocols',
  'tags',
  'taxon_determinations'
]

const params = defineModel({
  type: Object,
  default: () => ({})
})
</script>
