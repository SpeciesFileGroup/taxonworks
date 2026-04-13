<template>
  <PreviousLeads v-if="!!store.ancestors || !!store.futures" />
</template>

<script setup>
import useStore from '../store/leadStore.js'
import PreviousLeads from './components/PreviousLeads.vue'

const store = useStore()
</script>

<style lang="scss" scoped>
</style>