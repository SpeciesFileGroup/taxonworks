<template>
  <FacetText
    v-model="params"
    title="Name"
    param-text="name"
    param-exact="name_exact"
  />

  <FacetText
    v-model="params"
    title="URI"
    param-text="uri"
    param-exact="uri_exact"
  />

  <FacetOriginType
    v-model="params"
  />

  <FacetOtu
    v-model="params"
    target="AnatomicalPart"
  />

  <FacetPreparationType
    v-model="params"
    target="AnatomicalPart"
  />

  <FacetUsers
   v-model="params"
  />

  <FacetWith
    :options="IS_MATERIAL_OPTIONS"
    title="Is material"
    param="is_material"
    v-model="params"
  />

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
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetText from '@/components/Filter/Facets/shared/FacetText.vue'
import FacetOriginType from '@/components/Filter/Facets/AnatomicalParts/FacetOriginType.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetPreparationType from '@/components/Filter/Facets/PreparationType/FacetPreparationType.vue'
import FacetOtu from '@/components/Filter/Facets/Otu/FacetOtu.vue'

const IS_MATERIAL_OPTIONS = [
  {
    label: 'Both',
    value: undefined
  },
  {
    label: 'Is material',
    value: true
  },
  {
    label: 'Is not material',
    value: false
  }
]

const WITH_PARAMS = [ 'preparation_type' ]

const params = defineModel({
  type: Object,
  default: () => ({})
})

</script>

<style scoped>
.subj-obj {
  margin-bottom: 1.5em;
}
</style>