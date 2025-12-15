<template>
  <FacetContainer>
    <h3>Otu</h3>
    <label>
      <input
        type="checkbox"
        v-model="params.validity"
      />
      Linked to valid only
    </label>
    <label>
      <input
        type="checkbox"
        v-model="params.otus"
      />
      Show taxon names with OTUs only
    </label>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const params = defineModel({
  type: Object,
  required: true
})
</script>
