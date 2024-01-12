<template>
  <h1>New field occurrence</h1>
  <div>
    <HeaderBar />
    <BlockLayout>
      <template #header>
        <h3>Collecting event</h3>
      </template>
      <template #body>
        <CollectingEventForm />
      </template>
    </BlockLayout>
    <div class="flexbox">
      <FieldOccurrenceForm />
      <TaxonDeterminationForm />
    </div>
  </div>
</template>

<script setup>
import useStore from './store/store'
import TaxonDeterminationForm from './components/TaxonDeterminationForm.vue'
import CollectingEventForm from '@/components/Form/FormCollectingEvent/FormCollectingEvent.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import HeaderBar from './components/HeaderBar.vue'
import FieldOccurrenceForm from './components/FieldOccurenceForm/FieldOccurrenceForm.vue'

const store = useStore()
</script>
