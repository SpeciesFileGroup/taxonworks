<template>
  <FacetGeographic v-model="params" />
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
</template>

<script setup>
import { computed } from 'vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetGeographic from 'components/Filter/Facets/shared/FacetGeographic'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetOtu from 'components/Filter/Facets/Otu/FacetOtu.vue'
import FacetWKT from 'components/Filter/Facets/Otu/FacetWKT.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'

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

const WITH_PARAMS = ['origin_citations']

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
