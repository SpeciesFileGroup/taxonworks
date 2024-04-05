<template>
  <FacetFileExtension
    v-model="params"
    :extensions="['.nex, .nxs']"
  />
</template>

<script setup>
import FacetFileExtension from './FacetFileExtension.vue'

const params = defineModel()
</script>
