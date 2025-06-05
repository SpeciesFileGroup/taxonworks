import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  CONTENT,
  DESCRIPTOR,
  EXTRACT,
  FIELD_OCCURRENCE,
  IMAGE,
  LOAN,
  OTU,
  PEOPLE,
  SOUND,
  SOURCE,
} from '@/constants'
import AnnotatorTag from '../components/Annotator/AnnotatorTag.vue'
import AnnotatorNote from '../components/Annotator/AnnotatorNote.vue'
import AnnotatorConfidence from '../components/Annotator/Confidence/ConfidenceMain.vue'
import AnnotatorAttribution from '../components/Annotator/Attribution/AttributionMain.vue'
import AnnotatorCitation from '../components/Annotator/AnnotatorCitation.vue'
import AnnotatorDataAttribute from '../components/Annotator/DataAttribute/DataAttributeMain.vue'
import AnnotatorIdentifier from '../components/Annotator/Identifier/IdentifierMain.vue'
import AnnotatorProtocol from '../components/Annotator/Protocol/ProtocolMain.vue'

const TAG_SLICE = {
  Tags: AnnotatorTag
}

const NOTE_SLICE = {
  Notes: AnnotatorNote
}

const CONFIDENCE_SLICE = {
  Confidence: AnnotatorConfidence
}

const ATTRIBUTION_SLICE = {
  Attribution: AnnotatorAttribution
}

const CITATION_SLICE = {
  Citations: AnnotatorCitation
}

const DATA_ATTRIBUTE_SLICE = {
  'Data attributes': AnnotatorDataAttribute
}

const PROTOCOL_SLICE = {
  Protocol: AnnotatorProtocol
}

const IDENTIFIER_SLICE = {
  Identifiers: AnnotatorIdentifier
}

function buildSliceObject(...slices) {
  return Object.assign({}, ...slices)
}

export const ANNOTATORS = {
  DEFAULT: {
    all: buildSliceObject(
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      PROTOCOL_SLICE
    ),

    ids: buildSliceObject(
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      NOTE_SLICE,
      PROTOCOL_SLICE,
      TAG_SLICE
    )
  },

  [COLLECTING_EVENT]: {
    all: buildSliceObject(
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      PROTOCOL_SLICE
    ),

    ids: buildSliceObject(
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      IDENTIFIER_SLICE,
      NOTE_SLICE,
      PROTOCOL_SLICE,
      TAG_SLICE
    )
  },

  [COLLECTION_OBJECT]: {
    all: buildSliceObject(
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      PROTOCOL_SLICE
    ),

    ids: buildSliceObject(
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      IDENTIFIER_SLICE,
      NOTE_SLICE,
      PROTOCOL_SLICE,
      TAG_SLICE
    )
  },

  [OTU]: {
    all: buildSliceObject(CONFIDENCE_SLICE, DATA_ATTRIBUTE_SLICE),

    ids: buildSliceObject(
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      NOTE_SLICE,
      TAG_SLICE
    )
  },

  [ASSERTED_DISTRIBUTION]: {
    all: buildSliceObject(CONFIDENCE_SLICE, DATA_ATTRIBUTE_SLICE),

    ids: buildSliceObject(
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      NOTE_SLICE,
      TAG_SLICE
    )
  },

  [BIOLOGICAL_ASSOCIATION]: {
    all: buildSliceObject(CONFIDENCE_SLICE, DATA_ATTRIBUTE_SLICE),

    ids: buildSliceObject(
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      NOTE_SLICE,
      TAG_SLICE
    )
  },

  [CONTENT]: {
    all: buildSliceObject(CONFIDENCE_SLICE, DATA_ATTRIBUTE_SLICE),

    ids: buildSliceObject(
      ATTRIBUTION_SLICE,
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE
    )
  },

  [DESCRIPTOR]: {
    all: buildSliceObject(CONFIDENCE_SLICE, DATA_ATTRIBUTE_SLICE),

    ids: buildSliceObject(
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      NOTE_SLICE,
      TAG_SLICE
    )
  },

  [EXTRACT]: {
    all: buildSliceObject(
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      PROTOCOL_SLICE
    ),

    ids: buildSliceObject(
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      PROTOCOL_SLICE,
      TAG_SLICE
    )
  },

  [IMAGE]: {
    all: buildSliceObject(CONFIDENCE_SLICE, PROTOCOL_SLICE),

    ids: buildSliceObject(
      ATTRIBUTION_SLICE,
      PROTOCOL_SLICE,
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      NOTE_SLICE,
      TAG_SLICE
    )
  },

  [FIELD_OCCURRENCE]: {
    all: buildSliceObject(
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      PROTOCOL_SLICE
    ),

    ids: buildSliceObject(
      PROTOCOL_SLICE,
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      NOTE_SLICE,
      TAG_SLICE
    )
  },

  [LOAN]: {
    all: buildSliceObject(DATA_ATTRIBUTE_SLICE),

    ids: buildSliceObject(DATA_ATTRIBUTE_SLICE, NOTE_SLICE, TAG_SLICE)
  },

  [PEOPLE]: {
    all: buildSliceObject(DATA_ATTRIBUTE_SLICE),

    ids: buildSliceObject(DATA_ATTRIBUTE_SLICE, NOTE_SLICE, TAG_SLICE)
  },

  [SOUND]: {
    all: buildSliceObject(
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      PROTOCOL_SLICE
    ),

    ids: buildSliceObject(
      ATTRIBUTION_SLICE,
      PROTOCOL_SLICE,
      CITATION_SLICE,
      CONFIDENCE_SLICE,
      DATA_ATTRIBUTE_SLICE,
      NOTE_SLICE,
      TAG_SLICE
    )
  },

  [SOURCE]: {
    all: buildSliceObject(DATA_ATTRIBUTE_SLICE),

    ids: buildSliceObject(DATA_ATTRIBUTE_SLICE, NOTE_SLICE, TAG_SLICE)
  }
}
