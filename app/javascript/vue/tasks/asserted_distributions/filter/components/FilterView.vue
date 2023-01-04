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
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetGeographic from 'components/Filter/Facets/shared/FacetGeographic'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetOtu from 'components/Filter/Facets/Otu/FacetOtu.vue'
import FacetWKT from 'components/Filter/Facets/Otu/FacetWKT.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'

const WITH_PARAMS = ['presence']

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
