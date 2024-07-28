<template>
  <DocumentSelector
    v-model="selectedDocs"
    class="document_selector"
  />

</template>

<script setup>
import DocumentSelector from './components/DocumentSelector.vue'
import { ref } from 'vue'

const selectedDocs = ref([])
</script>

<style lang="scss" scoped>
.document_selector {
  margin-bottom: 2em;
}
</style>