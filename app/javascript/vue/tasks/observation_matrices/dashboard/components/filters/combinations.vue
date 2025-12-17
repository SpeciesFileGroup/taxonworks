<template>
  <FacetContainer>
    <h3>Combinations</h3>
    <label>
      <input
        type="checkbox"
        v-model="combination"
      />
      Includes
    </label>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const combination = defineModel({
  type: Boolean,
  default: undefined
})
</script>
