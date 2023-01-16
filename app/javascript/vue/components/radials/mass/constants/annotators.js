import {
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

export const ANNOTATORS = {
  [ALTERNATE_VALUE]: {
    label: 'Alternate values'
  },
  [CITATION]: {
    label: 'Citations'
  },
  [CONFIDENCE]: {
    label: 'Confidence',
    component: AnnotatorConfidence
  },
  [DATA_ATTRIBUTE]: {
    label: 'Data attributes'
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
    label: 'Verifiers',
    //component: AnnotatorVerifier
  }
}
