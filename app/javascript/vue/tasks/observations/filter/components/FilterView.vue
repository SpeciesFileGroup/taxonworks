<template>
  <FacetDescriptor v-model="params" />
  <FacetDescriptorType v-model="params" />
  <FacetObservationMatrix v-model="params" />
  <FacetOtu
    v-model="params"
    :target="OBSERVATION"
  />
  <FacetTaxonName
    v-model="params"
    coverage
  />
  <FacetCollectionObject v-model="params" />
  <FacetTags
    v-model="params"
    target="Source"
  />
  <FacetUsers v-model="params" />
  <FacetNotes v-model="params" />
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
import { OBSERVATION } from 'constants/index.js'
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetObservationMatrix from 'components/Filter/Facets/shared/FacetObservationMatrix'
import FacetDescriptorType from 'components/Filter/Facets/shared/FacetDescriptorType.vue'
import FacetNotes from 'components/Filter/Facets/shared/FacetNotes.vue'
import FacetDescriptor from 'components/Filter/Facets/shared/FacetDescriptor.vue'
import FacetCollectionObject from 'components/Filter/Facets/CollectionObject/FacetCollectionObject.vue'
import FacetTaxonName from 'components/Filter/Facets/TaxonName/FacetTaxonName.vue'
import FacetOtu from 'components/Filter/Facets/Otu/FacetOtu.vue'

const WITH_PARAMS = ['depictions', 'notes']

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
