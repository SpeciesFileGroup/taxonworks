<template>
  <PreviousLeads v-if="store.lead.id" />
</template>

<script setup>
import useStore from '../store/leadStore.js'
import PreviousLeads from './components/PreviousLeads.vue'

const store = useStore()
</script>

<style lang="scss" scoped>
</style>