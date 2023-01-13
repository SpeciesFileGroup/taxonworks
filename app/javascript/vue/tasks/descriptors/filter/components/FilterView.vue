<template>
  <FacetTags
    v-model="params"
    target="Source"
  />
  <FacetIdentifiers v-model="params" />
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
import FacetTags from 'components/Filter/Facets/shared/FacetTags.vue'
import FacetIdentifiers from 'components/Filter/Facets/shared/FacetIdentifiers.vue'
import FacetWith from 'components/Filter/Facets/shared/FacetWith.vue'
import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'

const WITH_PARAMS = [
  'observation_matrices',
  'observations',
  'character_states',
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
