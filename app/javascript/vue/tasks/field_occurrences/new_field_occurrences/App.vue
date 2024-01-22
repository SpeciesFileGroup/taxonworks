<template>
  <h1>New field occurrence</h1>
  <div>
    <HeaderBar />
    <div class="horizontal-left-content align-start gap-medium">
      <div class="flex-wrap-column gap-medium">
        <FieldOccurrenceForm />
        <BiocurationForm />
        <IdentifierForm />
        <CitationForm />
        <TaxonDeterminationForm />
      </div>

      <CollectingEventForm class="full_width" />
    </div>
  </div>
</template>

<script setup>
import TaxonDeterminationForm from './components/TaxonDeterminationForm.vue'
import FieldOccurrenceForm from './components/FieldOccurenceForm/FieldOccurrenceForm.vue'
import HeaderBar from './components/HeaderBar.vue'
import CollectingEventForm from './components/CollectingEventForm.vue'
import IdentifierForm from './components/FieldOccurenceForm/Identifier/IdentifierForm.vue'
import CitationForm from './components/CitationForm.vue'
import BiocurationForm from './components/BiocurationForm.vue'

defineOptions({
  name: 'NewFieldOccurrence'
})
</script>
