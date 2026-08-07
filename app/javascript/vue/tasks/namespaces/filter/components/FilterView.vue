<template>
  <FacetByAttribute
    controller="namespaces"
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
</template>

<script setup>
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetByAttribute from '@/components/Filter/Facets/shared/FacetByAttributeRow/FacetByAttributeRow.vue'

const WITH_PARAMS = ['is_virtual']

const params = defineModel({
  type: Object,
  default: () => ({})
})
</script>
