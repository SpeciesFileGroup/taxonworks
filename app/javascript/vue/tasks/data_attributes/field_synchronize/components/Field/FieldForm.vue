<template>
  <BlockLayout>
    <template #header>
      <h3>Fields</h3>
    </template>
    <template #body>
      <PropertySelector
        :properties="attributes"
        v-model="selectedAttributes"
      />
      <PredicateSelector
        :predicates="predicates"
        v-model="selectedPredicates"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import PredicateSelector from './PredicateSelector.vue'
import PropertySelector from './PropertySelector.vue'

defineProps({
  attributes: {
    type: Array,
    default: () => []
  },

  predicates: {
    type: Array,
    default: () => []
  }
})

const selectedPredicates = defineModel('selectedPredicates', { type: Array })
const selectedAttributes = defineModel('selectedAttributes', { type: Array })
</script>
