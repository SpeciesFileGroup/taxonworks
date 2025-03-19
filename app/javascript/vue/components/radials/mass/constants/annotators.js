import AnnotatorTag from '../components/Annotator/AnnotatorTag.vue'
import AnnotatorNote from '../components/Annotator/AnnotatorNote.vue'
import AnnotatorConfidence from '../components/Annotator/Confidence/ConfidenceMain.vue'
import AnnotatorAttribution from '../components/Annotator/Attribution/AttributionMain.vue'
import AnnotatorCitation from '../components/Annotator/AnnotatorCitation.vue'
import AnnotatorDataAttribute from '../components/Annotator/DataAttribute/AnnotatorDataAttribute.vue'
import AnnotatorProtocol from '../components/Annotator/Protocol/ProtocolMain.vue'

export const ANNOTATORS = {
  all: {
    Confidence: AnnotatorConfidence,
    'Data attributes': AnnotatorDataAttribute,
    Protocol: AnnotatorProtocol
  },

  ids: {
    Attribution: AnnotatorAttribution,
    Citations: AnnotatorCitation,
    Confidence: AnnotatorConfidence,
    'Data attributes': AnnotatorDataAttribute,
    Notes: AnnotatorNote,
    Protocol: AnnotatorProtocol,
    Tags: AnnotatorTag
  }
}
