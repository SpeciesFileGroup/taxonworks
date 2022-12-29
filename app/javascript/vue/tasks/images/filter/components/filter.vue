<template>
  <FacetOtu
    v-model="params"
    target="Image"
  />
  <FacetTaxonName v-model="params" />
  <FacetAncestorTarget v-model="params" />
  <FacetCollectionObject v-model="params" />
  <FacetBiocurations v-model="params" />
  <FacetIdentifiers v-model="params" />
  <FacetTags
    target="Image"
    v-model="params"
  />
  <FacetUsers v-model="params" />
</template>

<script setup>
import { computed } from 'vue'
import FacetCollectionObject from 'components/Filter/Facets/CollectionObject/FacetCollectionObject.vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetBiocurations from 'components/Filter/Facets/CollectionObject/FacetBiocurations.vue'
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetIdentifiers from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetAncestorTarget from './filters/FacetAncestorTarget.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetOtu from 'components/Filter/Facets/Otu/FacetOtu.vue'

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
