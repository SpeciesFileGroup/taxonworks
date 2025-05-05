<template>
  <FacetDescriptorTerm v-model="params" />
  <FacetObservationMatrix v-model="params" />
  <FacetDescriptorType v-model="params" />
  <FacetTags
    v-model="params"
    :target="DESCRIPTOR"
  />
  <FacetConfidence
    v-model="params"
    :target="DESCRIPTOR"
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
  <FacetDiffModel v-model="params" />
</template>

<script setup>
import { computed } from 'vue'
import { DESCRIPTOR } from '@/constants'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetIdentifiers from '@/components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetObservationMatrix from '@/components/Filter/Facets/shared/FacetObservationMatrix.vue'
import FacetDescriptorType from '@/components/Filter/Facets/shared/FacetDescriptorType.vue'
import FacetNotes from '@/components/Filter/Facets/shared/FacetNotes.vue'
import FacetDescriptorTerm from '@/components/Filter/Facets/shared/FacetDescriptorTerm.vue'
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import FacetConfidence from '@/components/Filter/Facets/shared/FacetConfidence.vue'

const WITH_PARAMS = [
  'confidences',
  'observation_depictions',
  'observation_matrices',
  'observations'
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
  set: (value) => emit('update:modelValue', value)
})
</script>
