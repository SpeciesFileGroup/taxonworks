import dataAttributes from '../components/data_attribute/data_attribute_annotator.vue'
import biologicalAssociations from '../components/biological_relationships/biological_relationships_annotator.vue'
import assertedDistributions from '../components/asserted_distributions/asserted_distributions_annotator.vue'
import commonNames from '../components/common_names/main.vue'
import contents from '../components/contents/main.vue'
import biocurationClassifications from '../components/biocurations/biocurations.vue'
import taxonDeterminations from '../components/taxon_determinations/taxon_determinations.vue'
import observationMatrices from '../components/observation_matrices/main.vue'
import collectingEvent from '../components/collecting_event/main.vue'
import originRelationships from '../components/origin_relationship/main.vue'
import depictions from '../components/depictions/Depictions.vue'
import extracts from '../components/extract/Main.vue'
import AnatomicalParts from '../components/origin_relationship/create/AnatomicalParts.vue'

export const SLICE = {
  data_attributes: dataAttributes,
  biological_associations: biologicalAssociations,
  asserted_distributions: assertedDistributions,
  common_names: commonNames,
  contents,
  biocuration_classifications: biocurationClassifications,
  taxon_determinations: taxonDeterminations,
  observation_matrices: observationMatrices,
  collecting_event: collectingEvent,
  origin_relationships: originRelationships,
  extracts,
  depictions
}

export const SLICES_WITH_CREATE = {
  origin_relationships: { // Created components must emit 'originRelationshipCreated' with value an origin relationship
    // The value of 'flip' is true if component should only be displayed when
    // flip is true, false if component should only be displayed when flip is
    // false, and null if component should be displayed in either case.
    AnatomicalPart: {
      component: AnatomicalParts,
      flip: false,
    }
  }
}
