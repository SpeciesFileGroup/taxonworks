import {
  ATTRIBUTION,
  ALTERNATE_VALUE,
  CITATION,
  CONFIDENCE,
  DATA_ATTRIBUTE,
  DEPICTION,
  DOCUMENTATION,
  IDENTIFIER,
  NOTE,
  TAG,
  VERIFIER
} from 'constants/index.js'

import AnnotatorTag from '../components/Annotator/AnnotatorTag.vue'
import AnnotatorNote from '../components/Annotator/AnnotatorNote.vue'
import AnnotatorConfidence from '../components/Annotator/AnnotatorConfidence.vue'
import AnnotatorVerifier from '../components/Annotator/AnnotatorVerifier.vue'
import AnnotatorAttribution from '../components/Annotator/Attribution/AttributionMain.vue'
import AnnotatorCitation from '../components/Annotator/AnnotatorCitation.vue'
import AnnotatorDataAttribute from '../components/Annotator/AnnotatorDataAttribute.vue'

export const ANNOTATORS = {
  [ALTERNATE_VALUE]: {
    label: 'Alternate values'
  },
  [ATTRIBUTION]: {
    label: 'Attribution',
    component: AnnotatorAttribution
  },
  [CITATION]: {
    label: 'Citations',
    component: AnnotatorCitation
  },
  [CONFIDENCE]: {
    label: 'Confidence',
    component: AnnotatorConfidence
  },
  [DATA_ATTRIBUTE]: {
    label: 'Data attributes',
    component: AnnotatorDataAttribute
  },
  [DEPICTION]: {
    label: 'Depictions'
  },
  [DOCUMENTATION]: {
    label: 'Documentations'
  },
  [IDENTIFIER]: {
    label: 'Identifiers'
  },
  [NOTE]: {
    label: 'Notes',
    component: AnnotatorNote
  },
  [TAG]: {
    label: 'Tags',
    component: AnnotatorTag
  },
  [VERIFIER]: {
    label: 'Verifiers'
    //component: AnnotatorVerifier
  }
}
