<template>
  <FacetGeographic v-model="params" />
  <FacetAssertedDistributionShapeType v-model="params" />
  <FacetWKT v-model="params" />
  <FacetTaxonName
    v-model="params"
    coverage
  />
  <FacetOtu
    target="AssertedDistribution"
    v-model="params"
  />
  <FacetUsers v-model="params" />
  <FacetNotes v-model="params" />
  <FacetTags
    :target="ASSERTED_DISTRIBUTION"
    v-model="params"
  />
  <FacetConfidence
    v-model="params"
    :target="ASSERTED_DISTRIBUTION"
  />
  <FacetDataAttribute v-model="params" />
  <FacetWith
    v-for="param in WITH_PARAMS"
    :key="param"
    :title="param"
    :param="param"
    v-model="params"
  />
  <FacetWith
    :options="PRESENCE_OPTIONS"
    title="presence"
    param="presence"
    v-model="params"
  />
  <FacetDiffModel v-model="params" />
</template>

<script setup>
import { computed } from 'vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetGeographic from '@/components/Filter/Facets/shared/FacetGeographic.vue'
import FacetAssertedDistributionShapeType from '@/components/Filter/Facets/AssertedDistributions/FacetAssertedDistributionShapeType.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetOtu from '@/components/Filter/Facets/Otu/FacetOtu.vue'
import FacetWKT from '@/components/Filter/Facets/Otu/FacetWKT.vue'
import FacetNotes from '@/components/Filter/Facets/shared/FacetNotes.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetDataAttribute from '@/components/Filter/Facets/shared/FacetDataAttribute/FacetDataAttribute.vue'
import FacetTaxonName from '@/components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import FacetConfidence from '@/components/Filter/Facets/shared/FacetConfidence.vue'
import { ASSERTED_DISTRIBUTION } from '@/constants/index.js'

const PRESENCE_OPTIONS = [
  {
    label: 'Both',
    value: undefined
  },
  {
    label: 'Present',
    value: true
  },
  {
    label: 'Absent',
    value: false
  }
]

const WITH_PARAMS = ['confidences', 'origin_citations']

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
