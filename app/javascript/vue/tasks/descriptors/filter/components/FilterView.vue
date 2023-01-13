<template>
  <FacetDescriptorTerm v-model="params" />
  <FacetObservationMatrix v-model="params" />
  <FacetDescriptorType v-model="params" />
  <FacetTags
    v-model="params"
    target="Source"
  />
  <FacetIdentifiers v-model="params" />
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
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetIdentifiers from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'
import FacetObservationMatrix from './Facet/FacetObservationMatrix'
import FacetDescriptorType from './Facet/FacetDescriptorType.vue'
import FacetNotes from 'components/Filter/Facets/shared/FacetNotes.vue'
import FacetDescriptorTerm from './Facet/FacetDescriptorTerm.vue'

const WITH_PARAMS = [
  'observation_matrices',
  'observations',
  'observation_depictions'
]

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

</script>
