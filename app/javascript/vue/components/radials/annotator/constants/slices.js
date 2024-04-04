import confidences from '../components/confidence/confidence_annotator.vue'
import depictions from '../components/depictions/depiction_annotator.vue'
import documentation from '../components/documentation_annotator.vue'
import identifiers from '../components/identifier/identifier_annotator.vue'
import tags from '../components/tag_annotator.vue'
import notes from '../components/note_annotator.vue'
import dataAttributes from '../components/data_attribute_annotator.vue'
import alternateValues from '../components/alternate_value_annotator.vue'
import citations from '../components/citations/citation_annotator.vue'
import protocolRelationships from '../components/protocol_annotator.vue'
import attribution from '../components/attribution/main.vue'
import verifiers from '../components/verifiers/Verifiers.vue'

export const SLICE = {
  confidences,
  depictions,
  documentation,
  identifiers,
  tags,
  notes,
  data_attributes: dataAttributes,
  alternate_values: alternateValues,
  citations,
  protocol_relationships: protocolRelationships,
  attribution,
  verifiers
}
