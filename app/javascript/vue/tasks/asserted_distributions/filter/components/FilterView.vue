<template>
  <FacetGeographic v-model="params" />
  <FacetWKT v-model="params" />
  <FacetOtu
    target="AssertedDistribution"
    v-model="params"
  />
  <FacetTaxonName
    v-model="params"
    coverage
  />
  <FacetUsers v-model="params" />
</template>

<script setup>

import { computed } from 'vue'
import FacetGeographic from 'components/Filter/Facets/shared/FacetGeographic'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetOtu from 'components/Filter/Facets/Otu/FacetOtu.vue'
import FacetWKT from 'components/Filter/Facets/Otu/FacetWKT.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'

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
