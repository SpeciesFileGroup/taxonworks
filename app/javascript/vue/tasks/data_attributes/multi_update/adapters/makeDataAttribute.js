import { randomUUID } from '@/helpers'
export function makeDataAttribute(da) {
  return {
    id: da.id,
    uuid: randomUUID(),
    value: da.value,
    predicateId: da.controlled_vocabulary_term_id,
    objectId: da.attribute_subject_id,
    objectType: da.attribute_subject_type,
    isUnsaved: false
  }
}
