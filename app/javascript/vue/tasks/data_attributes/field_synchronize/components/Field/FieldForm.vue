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
      <div class="horizontal-left-content gap-small align-end">
        <PredicateSelector
          :predicates="predicates"
          v-model="selectedPredicates"
        />
        <ModalPredicates
          :predicates="predicates"
          @select="(item) => emit('user-predicate', item)"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import PredicateSelector from './PredicateSelector.vue'
import PropertySelector from './PropertySelector.vue'
import ModalPredicates from './ModalPredicates.vue'

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

const emit = defineEmits(['user-predicate'])

const selectedPredicates = defineModel('selectedPredicates', { type: Array })
const selectedAttributes = defineModel('selectedAttributes', { type: Array })
</script>
