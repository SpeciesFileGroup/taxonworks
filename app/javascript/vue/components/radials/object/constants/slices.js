import dataAttributes from '../components/data_attribute/data_attribute_annotator.vue'
import biologicalAssociations from '../components/biological_relationships/biological_relationships_annotator.vue'
import assertedDistributions from '../components/asserted_distributions/asserted_distributions_annotator.vue'
import commonNames from '../components/common_names/main.vue'
import contents from '../components/contents/main.vue'
import biocurationClassifications from '../components/biocurations/biocurations'
import taxonDeterminations from '../components/taxon_determinations/taxon_determinations'
import observationMatrices from '../components/observation_matrices/main.vue'
import collectingEvent from '../components/collecting_event/main.vue'
import originRelationships from '../components/origin_relationship/main'
import depictions from '../components/depictions/Depictions.vue'
import extracts from '../components/extract/Main.vue'

export const SLICE = {
  data_attributes: dataAttributes,
  biological_associations: biologicalAssociations,
  asserted_distributions: assertedDistributions,
  common_names: commonNames,
  contents,
  biocuration_classifications: biocurationClassifications,
  taxon_determinations: taxonDeterminations,
  observation_matricesAnnotator: observationMatrices,
  collecting_event: collectingEvent,
  origin_relationships: originRelationships,
  extracts,
  depictions
}
