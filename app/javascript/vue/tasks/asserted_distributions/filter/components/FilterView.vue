<template>
  <FacetGeographic v-model="params" />
  <FacetWKT v-model="params" />
  <FacetOtu
    target="AssertedDistribution"
    v-model="params"
  />
  <FacetUsers v-model="params" />
</template>

<script setup>

import { computed } from 'vue'
import FacetGeographic from 'components/Filter/Facets/shared/FacetGeographic'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetOtu from 'components/Filter/Facets/Otu/FacetOtu.vue'
import FacetWKT from 'components/Filter/Facets/Otu/FacetWKT.vue'

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
