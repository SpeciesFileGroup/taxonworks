<template>
  <FacetText
    v-model="params"
    title="URI"
    param-text="uri"
    param-exact="uri_exact"
  />

  <FacetText
    v-model="params"
    title="URI label"
    param-text="uri_label"
    param-exact="uri_label_exact"
  />

  <FacetAssertedEnvironmentObjectType v-model="params" />

  <FacetNotes v-model="params" />

  <FacetTags
    v-model="params"
    target="AssertedEnvironment"
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
import FacetDataAttribute from '@/components/Filter/Facets/shared/FacetDataAttribute/FacetDataAttribute.vue'
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetText from '@/components/Filter/Facets/shared/FacetText.vue'
import FacetNotes from '@/components/Filter/Facets/shared/FacetNotes.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetAssertedEnvironmentObjectType from '@/components/Filter/Facets/AssertedEnvironments/FacetAssertedEnvironmentObjectType.vue'

const WITH_PARAMS = ['citations']

const params = defineModel({
  type: Object,
  default: () => ({})
})
</script>
