<template>
  <h1>New field occurrence</h1>
  <div>
    <TaxonDeterminationForm />
  </div>
</template>

<script setup>
import useStore from './store/store'
import TaxonDeterminationForm from './components/TaxonDeterminationForm.vue'

const store = useStore()
</script>
