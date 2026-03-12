import TaxonDeterminationForm from '../components/TaxonDeterminationForm.vue'
import FieldOccurrenceForm from '../components/FieldOccurenceForm/FieldOccurrenceForm.vue'
import CitationForm from '../components/CitationForm.vue'
import BiocurationForm from '../components/BiocurationForm.vue'
import BiologicalAssociation from '../components/BiologicalAssociation.vue'
import VDepiction from '../components/Depiction/Depiction.vue'
import OriginRelationship from '../components/OriginRelationship.vue'

export default {
  FieldOccurrenceForm: {
    component: FieldOccurrenceForm,
    title: 'Field Occurrence'
  },
  TaxonDeterminationForm: {
    component: TaxonDeterminationForm,
    title: 'Taxon Determinations'
  },
  BiologicalAssociation: {
    component: BiologicalAssociation,
    title: 'Biological Associations'
  },
  BiocurationForm: {
    component: BiocurationForm,
    title: 'Biocurations'
  },
  OriginRelationship: {
    component: OriginRelationship,
    title: 'Origin Relationships'
  },
  VDepiction: {
    component: VDepiction,
    title: 'Depictions'
  },
  CitationForm: {
    component: CitationForm,
    title: 'Citations'
  }
}
