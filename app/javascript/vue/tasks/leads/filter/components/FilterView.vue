<template>
  <FacetText
    v-model="params"
    title="Title"
    param-text="text"
    param-exact="text_exact"
  />

  <FacetText
    v-model="params"
    title="Description"
    param-text="description"
  />

  <FacetWith
    v-model="params"
    title="Key type"
    param="is_virtual"
    :options="KEY_TYPE_OPTIONS"
  />

  <FacetOtu
    v-model="params"
    :target="LEAD"
  />

  <FacetObservationMatrix v-model="params" />

  <FacetTags
    v-model="params"
    :target="LEAD"
  />

  <FacetDataAttribute v-model="params" />

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
import { LEAD } from '@/constants/index.js'
import FacetDataAttribute from '@/components/Filter/Facets/shared/FacetDataAttribute/FacetDataAttribute.vue'
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import FacetObservationMatrix from '@/components/Filter/Facets/shared/FacetObservationMatrix.vue'
import FacetOtu from '@/components/Filter/Facets/Otu/FacetOtu.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetText from '@/components/Filter/Facets/shared/FacetText.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'

const KEY_TYPE_OPTIONS = [
  { label: 'Both', value: undefined },
  { label: 'Dichotomous', value: false },
  { label: 'Simple', value: true }
]

const WITH_PARAMS = [
  'is_public',
  'otus',
  'observation_matrix',
  'citations',
  'data_attributes',
  'tags'
]

const params = defineModel({
  type: Object,
  default: () => ({})
})
</script>
