<template>
  <FacetName
    v-model="params"
    title="Name"
    param-text="name"
    param-exact="name_exact"
  />
  <FacetContainerType v-model="params" />
  <FacetIdentifiers v-model="params" />
  <FacetMatchIdentifiers v-model="params" />
  <FacetFillState v-model="params" />
  <FacetContainerSize v-model="params" />
  <FacetContainedObjectType v-model="params" />
  <FacetTags
    v-model="params"
    :target="CONTAINER"
  />
  <FacetUsers v-model="params" />
</template>

<script setup>
import { computed } from 'vue'
import { CONTAINER } from '@/constants/index.js'
import FacetContainerType from '@/components/Filter/Facets/Container/FacetContainerType.vue'
import FacetContainerSize from '@/components/Filter/Facets/Container/FacetContainerSize.vue'
import FacetContainedObjectType from '@/components/Filter/Facets/Container/FacetContainedObjectType.vue'
import FacetFillState from '@/components/Filter/Facets/Container/FacetFillState.vue'
import FacetIdentifiers from '@/components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetMatchIdentifiers from '@/components/Filter/Facets/shared/FacetMatchIdentifiers.vue'
import FacetName from '@/components/Filter/Facets/shared/FacetText.vue'
import FacetTags from '@/components/Filter/Facets/shared/FacetTags.vue'
import FacetUsers from '@/components/Filter/Facets/shared/FacetHousekeeping/FacetHousekeeping.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
