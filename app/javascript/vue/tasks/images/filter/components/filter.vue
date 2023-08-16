<template>
  <FacetOtu
    v-model="params"
    target="Image"
    includes
    coordinate
  />
  <FacetTaxonName v-model="params">
    <template #bottom>
      <FacetAncestorTarget v-model="params" />
    </template>
  </FacetTaxonName>
  <FacetDepictionObjectType v-model="params" />
  <FacetCollectionObject
    v-model="params"
    includes
  />
  <FacetBiocurations v-model="params" />
  <FacetIdentifiers v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetTags
    target="Image"
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
import { computed } from 'vue'
import FacetCollectionObject from '@/components/Filter/Facets/CollectionObject/FacetCollectionObject.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetUsers.vue'
import FacetBiocurations from '@/components/Filter/Facets/CollectionObject/FacetBiocurations.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetIdentifiers from '@/components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetAncestorTarget from './filters/FacetAncestorTarget.vue'
import FacetTaxonName from '@/components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetOtu from '@/components/Filter/Facets/Otu/FacetOtu.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetDepictionObjectType from '@/components/Filter/Facets/Depiction/FacetDepictionObjectType.vue'
import FacetMatchIdentifiers from '@/components/Filter/Facets/shared/FacetMatchIdentifiers.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const WITH_PARAMS = [
  'citations',
  'depictions',
  'type_material_depictions',
  'origin_citation'
]

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
