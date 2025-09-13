<template>
  <FacetOtu
    v-model="params"
    :target="CONTENT"
  />
  <FacetTopic
    v-model="params"
    :target="CONTENT"
  />
  <FacetConfidence
    v-model="params"
    :target="CONTENT"
  />
  <FacetParamExact
    title="Content"
    v-model="params"
    label="text"
    param="text"
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
  <FacetDiffModel v-model="params" />
</template>

<script setup>
import { computed } from 'vue'
import { CONTENT } from '@/constants/index.js'
import FacetWith from '@/components/Filter/Facets/shared/FacetWith.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'
import FacetTopic from '@/components/Filter/Facets/shared/FacetTopic.vue'
import FacetNotes from '@/components/Filter/Facets/shared/FacetNotes.vue'
import FacetParamExact from '@/components/Filter/Facets/shared/FacetParamExact.vue'
import FacetOtu from '@/components/Filter/Facets/Otu/FacetOtu.vue'
import FacetDiffModel from '@/components/Filter/Facets/shared/FacetDiffMode.vue'
import FacetConfidence from '@/components/Filter/Facets/shared/FacetConfidence.vue'

const WITH_PARAMS = [
  'citations',
  'confidences',
  'depictions',
  'origin_citation'
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
