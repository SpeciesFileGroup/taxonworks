<template>
  <DocumentSelector v-model="nexusDoc" />
</template>

<script setup>
import DocumentSelector from './components/DocumentSelector.vue'
import { ref } from 'vue'

const nexusDoc = ref()
</script>