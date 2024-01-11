<template>
  <h1>New field occurrence</h1>
  <div>
    <TaxonDeterminationForm />
    <CollectingEventForm />
  </div>
</template>

<script setup>
import useStore from './store/store'
import TaxonDeterminationForm from './components/TaxonDeterminationForm.vue'
import CollectingEventForm from '@/components/Form/FormCollectingEvent/FormCollectingEvent.vue'

const store = useStore()
</script>
