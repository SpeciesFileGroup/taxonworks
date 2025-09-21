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

  <FacetUsers
   v-model="params"
  />

  <FacetWith
    :options="IS_MATERIAL_OPTIONS"
    title="Is material"
    param="is_material"
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