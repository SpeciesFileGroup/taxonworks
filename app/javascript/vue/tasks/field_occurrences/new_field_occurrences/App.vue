<template>
  <h1>New field occurrence</h1>
  <div>
    <HeaderBar />
    <div class="horizontal-left-content align-start gap-medium">
      <div class="flex-wrap-column gap-medium left-column">
        <FieldOccurrenceForm />
        <BiocurationForm />
        <IdentifierForm />
        <CitationForm />
        <TaxonDeterminationForm />
      </div>

      <CollectingEventForm class="right-column" />
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

<style scoped>
.left-column {
  max-width: 25%;
  min-width: 440px;
}

.right-column {
  display: flex;
  flex-grow: 2;
}
</style>
