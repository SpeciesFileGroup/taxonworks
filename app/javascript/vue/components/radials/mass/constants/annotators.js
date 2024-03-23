import AnnotatorTag from '../components/Annotator/AnnotatorTag.vue'
import AnnotatorNote from '../components/Annotator/AnnotatorNote.vue'
import AnnotatorConfidence from '../components/Annotator/AnnotatorConfidence.vue'
import AnnotatorVerifier from '../components/Annotator/AnnotatorVerifier.vue'
import AnnotatorAttribution from '../components/Annotator/Attribution/AttributionMain.vue'
import AnnotatorCitation from '../components/Annotator/AnnotatorCitation.vue'
import AnnotatorDataAttribute from '../components/Annotator/DataAttribute/AnnotatorDataAttribute.vue'

export const ANNOTATORS = {
  all: {
    'Data attributes': AnnotatorDataAttribute
  },

  ids: {
    Attribution: AnnotatorAttribution,
    Citations: AnnotatorCitation,
    Confidence: AnnotatorConfidence,
    'Data attributes': AnnotatorDataAttribute,
    Notes: AnnotatorNote,
    Tags: AnnotatorTag
  }
}
