<template>
  <h1>New field occurrence</h1>
  <div>
    <HeaderBar />
    <div class="horizontal-left-content align-start gap-medium">
      <div class="flex-wrap-column gap-medium left-column">
        <FieldOccurrenceForm />
        <TaxonDeterminationForm />
        <BiologicalAssociation />
        <BiocurationForm />
        <OriginRelationship />
        <VDepiction />
        <CitationForm />
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
import CitationForm from './components/CitationForm.vue'
import BiocurationForm from './components/BiocurationForm.vue'
import BiologicalAssociation from './components/BiologicalAssociation.vue'
import VDepiction from './components/Depiction/Depiction.vue'
import OriginRelationship from './components/OriginRelationship.vue'

defineOptions({
  name: 'NewFieldOccurrence'
})
</script>

<style scoped>
.left-column {
  max-width: 25%;
  min-width: 500px;
}

.right-column {
  display: flex;
  flex-grow: 2;
}
</style>
