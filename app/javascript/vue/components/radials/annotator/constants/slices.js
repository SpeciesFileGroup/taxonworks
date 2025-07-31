import alternateValues from '../components/alternate_value_annotator.vue'
import attribution from '../components/attribution/main.vue'
import citations from '../components/citations/citation_annotator.vue'
import confidences from '../components/confidence/confidence_annotator.vue'
import conveyances from '../components/conveyances/ConveyanceMain.vue'
import dataAttributes from '../components/data_attribute_annotator.vue'
import depictions from '../components/depictions/depiction_annotator.vue'
import documentation from '../components/documentation_annotator.vue'
import identifiers from '../components/identifier/identifier_annotator.vue'
import notes from '../components/note_annotator.vue'
import protocolRelationships from '../components/protocol_annotator.vue'
import tags from '../components/tag_annotator.vue'
import verifiers from '../components/verifiers/Verifiers.vue'

export const SLICE = {
  alternate_values: alternateValues,
  attribution,
  citations,
  confidences,
  conveyances,
  data_attributes: dataAttributes,
  depictions,
  documentation,
  identifiers,
  notes,
  protocol_relationships: protocolRelationships,
  tags,
  verifiers
}
