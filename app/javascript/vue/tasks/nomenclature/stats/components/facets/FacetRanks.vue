<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <RankCheckboxList
      v-if="taxonName"
      :taxon-name="taxonName"
      :rank-list="rankList"
      v-model="params[param]"
    />
    <span
      v-else
      class="subtle"
    >
      Select a taxon name to choose ranks.
    </span>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import RankCheckboxList from './RankCheckboxList.vue'

const props = defineProps({
  title: {
    type: String,
    required: true
  },

  param: {
    type: String,
    required: true
  },

  taxonName: {
    type: Object,
    default: undefined
  },

  rankList: {
    type: Object,
    default: () => ({})
  },

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
