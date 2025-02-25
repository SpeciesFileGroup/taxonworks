import {
  COLLECTING_EVENT_PROPERTIES,
  FIELD_OCCURRENCE_PROPERTIES,
  TAXON_DETERMINATION_PROPERTIES,
  IDENTIFIER_PROPERTIES,
  DWC_OCCURRENCE_PROPERTIES
} from '@/shared/Filter/constants'

export const LAYOUTS = {
  All: {
    properties: {
      field_occurrence: FIELD_OCCURRENCE_PROPERTIES,
      collecting_event: COLLECTING_EVENT_PROPERTIES,
      taxon_determinations: TAXON_DETERMINATION_PROPERTIES,
      dwc_occurrence: DWC_OCCURRENCE_PROPERTIES,
      identifiers: IDENTIFIER_PROPERTIES
    },
    includes: {
      data_attributes: true
    }
  }
}
