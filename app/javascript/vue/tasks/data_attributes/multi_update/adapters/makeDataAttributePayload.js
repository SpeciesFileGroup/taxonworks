import { DATA_ATTRIBUTE } from '@/constants'

export function makeDataAttributePayload(data) {
  return {
    data_attribute: {
      attribute_subject_id: data.objectId,
      attribute_subject_type: data.objectType,
      controlled_vocabulary_term_id: data.predicateId,
      type: DATA_ATTRIBUTE,
      value: data.value
    }
  }
}
